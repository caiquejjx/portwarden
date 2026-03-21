import SwiftUI

struct PortRowView: View {
    // Pure data model provided by the parent
    let process: PortProcess
    
    // Closure triggered when the kill button is clicked
    let killAction: () -> Void
    
    // State to track row-based hover
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 8) {
            
            // 1. Status Dot
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            
            // 2. Process Name
            Text(process.processName)
                .font(.system(size: 13))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 120, alignment: .leading)
            
            // 3. Port Number (Formatted to strip commas)
            Text(":\(String(process.portNumber))")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .lineLimit(1)
           
            
            // 4. Spacer (pushes everything else to the right)
            Spacer()
            
            // 👇 FIX: Swap PID and Button smoothy 👇
            
            // 5. Container for the overlapping views
            // alignment: .trailing ensures they stick to the right edge
            ZStack(alignment: .trailing) {
                            
                            // --- VIEW A: The PID ---
                            Text("PID \(String(process.id))")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                // Fade out and shrink when hovering
                                .opacity(isHovering ? 0.0 : 1.0)
                                .scaleEffect(isHovering ? 0.8 : 1.0, anchor: .trailing)
                            
                            // --- VIEW B: The Kill Button ---
                            Button(action: killAction) {
                                Image(systemName: "stop.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14, weight: .bold))
                                    .frame(width: 20, height: 20)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            // Fade in and grow to normal size when hovering
                            .opacity(isHovering ? 1.0 : 0.0)
                            .scaleEffect(isHovering ? 1.0 : 0.8, anchor: .trailing)
                            // CRUCIAL: Prevent the invisible button from being clicked
                            .disabled(!isHovering)
                        }
                        .frame(width: 70, alignment: .trailing)
        }
        .padding(.vertical, 4)
        // ----------------------------------------------------
        // The magical SwiftUI hover modifier on the entire row
        .onHover { hovering in
            // We apply the animation directly to the state change
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self.isHovering = hovering
            }
        }
    }
}
