//
//  mouseDownFix.swift
//  This fix opens the menubar extra on mousedown instead of the mouseup event
//
//  Created by Sake Salverda on 30/03/2024.
//

import SwiftUI
import MenuBarExtraAccess

@Observable
class MouseDownFixDelegate {
    @ObservationIgnored
    var isPresented: Bool = false
    
    @ObservationIgnored
    var statusItem: NSStatusItem? = nil
    
    @ObservationIgnored
    var monitor: Any?
    
    deinit {
        NSEvent.removeMonitor(self.monitor)
    }
    
    init() {
        self.monitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            if let button = self?.statusItem?.button,
               event.window == button.window,
               (!event.modifierFlags.contains(.command) || button.window?.isKeyWindow == true) {
                self?.statusItem?.togglePresented()
                
                return nil
            }
            
            return event
        }
    }
}

extension Scene {
    func mouseDownFix(_ delegate: MouseDownFixDelegate) -> some Scene {
        @Bindable var delegate = delegate
        
        return self.menuBarExtraAccess(isPresented: $delegate.isPresented) { statusItem in
//            statusItem.sendAction(on: .leftMouseDown)
            delegate.statusItem = statusItem
        }
    }
}
