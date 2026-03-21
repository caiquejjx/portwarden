//
//  AppDelegate.swift
//  portwarden
//
//  Created by PFRDev ME LTDA on 3/19/26.
//
import SwiftUI
import Cocoa
import Foundation

struct PortStatusIndicator: View {
    let isActive: Bool
    var size: CGFloat = 8

    var body: some View {
        Circle()
            .fill(isActive ? Color.green : Color.gray)
            .frame(width: size, height: size)
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
  
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        scanner_init()
//    
//    }
    
    func applicationWillTerminate(_ notification: Notification) {
        scanner_deinit()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

