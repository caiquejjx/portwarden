const std = @import("std");
const c = @cImport({
    @cInclude("libproc.h");
});

pub const PidInfo = extern struct { pid: i32, port: u16, name: [128]u8, name_len: u8 };

pub const Scanner = struct {
    allocator: std.mem.Allocator,
    ports: std.ArrayList(PidInfo),

    pub fn init(allocator: std.mem.Allocator) Scanner {
        const ports: std.ArrayList(PidInfo) = .empty;
        return .{
            .allocator = allocator,
            .ports = ports,
        };
    }

    pub fn deinit(self: *Scanner) void {
        self.ports.deinit(self.allocator);
    }
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var scanner: Scanner = undefined;

pub export fn scanner_init() void {
    scanner = Scanner.init(gpa.allocator());
}

pub export fn scanner_deinit() void {
    scanner.deinit();
    _ = gpa.deinit();
}

pub export fn get_ports(out_len: *usize) [*]const PidInfo {
    scanner.ports.clearRetainingCapacity();
    const allocator = scanner.allocator;

    var pid_count: usize = @intCast(c.proc_listallpids(
        null,
        0,
    ));

    if (pid_count == 0) {
        std.debug.print("Error calling pid list\n", .{});
        return scanner.ports.items.ptr;
    }

    const pids_buffer = allocator.alloc(c.pid_t, pid_count) catch {
        return scanner.ports.items.ptr;
    };
    defer allocator.free(pids_buffer);

    pid_count = @intCast(c.proc_listallpids(
        pids_buffer.ptr,
        @intCast(pids_buffer.len * @sizeOf(c.pid_t)),
    ));

    for (pids_buffer[0..pid_count]) |pid| {
        var name: [128]u8 = undefined;
        const name_length = c.proc_name(pid, &name, 128);

        const bytes = c.proc_pidinfo(pid, c.PROC_PIDLISTFDS, 0, null, 0);
        if (bytes <= 0) {
            continue;
        }
        const fd_buffer = allocator.alloc(c.proc_fdinfo, @intCast(@divExact(bytes, @sizeOf(c.proc_fdinfo)))) catch {
            return scanner.ports.items.ptr;
        };
        defer allocator.free(fd_buffer);

        const result = c.proc_pidinfo(pid, c.PROC_PIDLISTFDS, 0, fd_buffer.ptr, bytes);

        var socket_info: c.socket_fdinfo = undefined;

        for (fd_buffer[0..@intCast(@divExact(result, @sizeOf(c.proc_fdinfo)))]) |fd_info| {
            if (fd_info.proc_fdtype == c.PROX_FDTYPE_SOCKET) {
                _ = c.proc_pidfdinfo(pid, fd_info.proc_fd, c.PROC_PIDFDSOCKETINFO, &socket_info, @sizeOf(c.socket_fdinfo));

                if (socket_info.psi.soi_family != c.AF_INET)
                    continue;

                if (socket_info.psi.soi_protocol == c.IPPROTO_TCP and socket_info.psi.soi_proto.pri_tcp.tcpsi_state == 1) {
                    const port = std.mem.bigToNative(
                        u16,
                        @as(u16, @intCast(socket_info.psi.soi_proto.pri_tcp.tcpsi_ini.insi_lport)),
                    );
                    var entry: PidInfo = undefined;

                    entry.pid = pid;
                    entry.port = port;
                    entry.name_len = @intCast(name_length);
                    std.mem.copyForwards(u8, entry.name[0..entry.name_len], name[0..entry.name_len]);

                    scanner.ports.append(allocator, entry) catch {
                        return scanner.ports.items.ptr;
                    };
                }
            }
        }
    }

    out_len.* = scanner.ports.items.len;

    return scanner.ports.items.ptr;
}
// pub fn main() !void {
//     scanner_init();
//     defer scanner_deinit();
//     var len: usize = 0;
//
//     const ptr = get_ports(&len);
//
//     const slice = ptr[0..len];
//
//     std.debug.print("size {d}", .{len});
//
//     for (slice) |entry| {
//         std.debug.print("name {d}\n", .{entry.name_len});
//     }
// }
