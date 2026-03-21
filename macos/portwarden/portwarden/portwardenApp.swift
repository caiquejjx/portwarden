import SwiftUI

@main
struct PortwardenApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = PortViewModel()
    
    var body: some Scene {
        MenuBarExtra("Portwarden", image: "gemini-svg") {
            
            // 👇 FIX 1: Wrap EVERYTHING in a single root VStack 👇
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Active Ports")
                    .font(.headline)
                    .padding([.top, .leading, .trailing], 12)
                    .padding(.bottom, 8)
                    .onAppear {
                        viewModel.refreshPorts()
                    }
                
                Divider()
                
                // 👇 FIX 2: Wrap the list in a ScrollView with a maxHeight 👇
                // This prevents 50 open ports from crashing the window constraints
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if viewModel.activePorts.isEmpty {
                            Text("No active ports found.")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(viewModel.activePorts) { process in
                                PortRowView(process: process) {
                                    viewModel.kill(pid: process.id)
                                }
                            }
                        }
                    }.padding(.horizontal, 12).padding(.vertical, 4)
                }
                .frame(maxHeight: 400).animation(.easeInOut(duration: 0.2), value: viewModel.activePorts)
                
                Divider()
                
                // Footer Actions
                VStack(alignment: .leading, spacing: 12) {
                    Button("Refresh List") {
                        viewModel.refreshPorts()
                    }
                    .buttonStyle(.plain) // Makes it look like a menu item instead of a grey box
                    
                    Button("Quit Portwarden") {
                        viewModel.quitApp()
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                
            }
            // 👇 FIX 3: Explicitly lock the window width here 👇
            .frame(width: 320)
            
        }
        .menuBarExtraStyle(.window)
    }
}
