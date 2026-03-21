import Foundation

// 1. The Data Structure
struct PortProcess: Identifiable, Equatable {
    let id: Int32 // The PID
    let portNumber: UInt16
    let processName: String
}
// 2. The Logic Engine
class PortScanner {
    
    // This is where you will eventually run 'lsof -i'
    func fetchActivePorts() -> [PortProcess] {
        var len: Int = 0
    
        
        let ptr = get_ports(&len)
        
        
        let buffer = UnsafeBufferPointer(start: ptr, count: len)
        
        var ports:[PortProcess] = []
       
        for port in buffer {
            let str = withUnsafeBytes(of: port.name) { rawBuffer in
                let slice = rawBuffer.prefix(Int(port.name_len))
                return String(decoding: slice, as: UTF8.self)
            }
            
            if ports.contains(where: { $0.id == port.pid }) { continue }
    
            ports.append(PortProcess(id: port.pid, portNumber: port.port, processName: str))
        }
        
        return ports
    }
    
    // We bring over our kill function from earlier!
    func killProcess(pid: Int32) -> Bool {
        let result = kill(pid, SIGTERM)
        return result == 0
    }
}
