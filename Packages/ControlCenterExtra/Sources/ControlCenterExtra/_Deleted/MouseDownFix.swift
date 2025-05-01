////
////  MouseDownFix.swift
////  PowerMode
////
////  Created by Sake Salverda on 10/01/2024.
////
//
//import AppKit
//import SwiftUI
//
//class MouseDownFix {
//    var monitor: LocalEventMonitor? = nil
//    var statusItem: NSStatusItem? = nil
//    
//    init() {
//        NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
////            self?.statusItem?.button?.sendAction(on: .leftMouseUp)
//            
//            if let button = self?.statusItem?.button,
//               event.window == button.window,
//               (!event.modifierFlags.contains(.command) || button.window?.isKeyWindow == true) {
//                
////                let actionSelector = button.action // "toggleWindow:" selector
////                print(actionSelector)
////                button.sendAction(actionSelector, to: button.target)
////                button.isHighlighted = button.state != .off
////                DistributedNotificationCenter.default().post(name: .beginMenuTracking, object: nil)
////                self?.statusItem?.togglePresented()
//                
////                self?.statusItem?.togglePresented()
////                self?.statusItem?.button?.sendAction(on: [.leftMouseDown])
////                button.performClick(button)
////                button.sendAction(on: .leftMouseUp)
////                let actionSelector = self?.statusItem?.button?.action
////                let target = self?.statusItem?.button?.target
////                self?.statusItem?.button?.sendAction(actionSelector, to: target)
//                
//                return nil
//            }
//            
//            return event
//        }
//        
////        monitor = LocalEventMonitor(mask: [.leftMouseDown]) { event in
////            if let button = self.statusItem?.button, event.window == button.window, (!event.modifierFlags.contains(.command) || button.window!.isKeyWindow) {
////                
//////                WLLNotificationCenter.Keys.statusbarDidClick.send(.rightMouseClicked)
//////                self.statusItem?.togglePresented()
//////                    button.performClick(nil)
//////                    AppState.shared.isPresented.toggle()
////
////                // Stop propagating the event so that the button remains highlighted.
////                return nil
////            }
////
////            return event
////        }
////        
////        monitor?.start()
//    }
//    
//    deinit {
//        monitor?.stop()
//    }
//}
