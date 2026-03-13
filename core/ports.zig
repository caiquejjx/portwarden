const std = @import("std");
const c = @cImport({
    @cInclude("libproc.h");
});
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var pid_count: usize = @intCast(c.proc_listallpids(
        null,
        0,
    ));

    if (pid_count == 0) {
        std.debug.print("Error calling pid list\n", .{});
        return;
    }

    const allocator = gpa.allocator();
    const buffer = try allocator.alloc(c.pid_t, pid_count);
    allocator.free(buffer);

    pid_count = @intCast(c.proc_listallpids(
        buffer.ptr,
        @intCast(buffer.len * @sizeOf(c.pid_t)),
    ));

    std.debug.print("{d} pids\n", .{pid_count});

    for (0..pid_count) |i| {
        const pid = buffer[i];
        std.debug.print("pid: {d}\n", .{pid});
        var name_buffer: [128]u8 = undefined;
        const name_length = c.proc_name(pid, &name_buffer, 128);

        if (name_length > 0) {
            std.debug.print("pid: {d} | name {s} \n", .{ pid, name_buffer[0..@intCast(name_length)] });
        }
    }
}
