import SwiftUI
import Combine
// ObservableObject tells the UI: "Hey, listen to me for updates!"
import SwiftUI

class PortViewModel: ObservableObject {
    
    @Published var activePorts: [PortProcess] = []
    
    // 1. Declare the scanner, but don't assign it yet
    private let scanner: PortScanner
    
    // 👇 ADD THIS: The explicit Initializer 👇
    init() {
        scanner_init()
        self.scanner = PortScanner()
        
 
        self.refreshPorts()
    }
    // 👆 ---------------------------------- 👆
    
    
    func refreshPorts() {
        self.activePorts = scanner.fetchActivePorts()
    }
    
    func kill(pid: Int32) {
        print("ViewModel attempting to kill PID: \(pid)")
        
        let success = scanner.killProcess(pid: pid)
        if success {
            refreshPorts()
        } else {
            print("Failed to kill process.")
        }
    }
    
    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
