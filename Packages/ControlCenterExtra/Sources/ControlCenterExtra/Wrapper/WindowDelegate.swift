//
//  File.swift
//  
//
//  Created by Sake Salverda on 25/03/2024.
//

import SwiftUI
import AppKit
import Combine
import OSLog

class ControlCenterWindowDelegate<Content: View>: NSObject, NSWindowDelegate {
    let window: NSPanel
    
    var statusItem: NSStatusItem?
    
    private let alignment: PopUpAlignment = .left
    private let screenClippingBehaviour: ScreenClippingBehaviour = .reverseAlignment
    
    private var statusItemVisibilityObservation: NSKeyValueObservation? = nil
    
    let isOpen: PassthroughSubject<Bool, Never> = .init()
    
    private var localEventMonitor: EventMonitor?
    private var globalEventMonitor: EventMonitor?
    
    init(_ title: String = "PowerMode", statusItem: NSStatusItem? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.statusItem = statusItem
        self.window = MenuWindow(title: title, content: content)
        
        super.init()
        
        window.delegate = self
        
        setupLocalMonitor()
        localEventMonitor?.start()
        
        // this only fires when clicked within the statusbar
        // not within the menu of other apps
        // nor within the rest of the window
        globalEventMonitor = GlobalEventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let window = self?.window, window.isKeyWindow {
                // Resign key window status if a external non-activating event is triggered,
                // such as other system status bar menus.
                
                window.resignKey()
            }
        }
    }
    
    deinit {
        statusItemVisibilityObservation?.invalidate()
        
        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
    
    private func setupLocalMonitor() {
        localEventMonitor = LocalEventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let self, let button = self.statusItem?.button, event.window == button.window {
                switch (event.type, Optional<Bool>.none, event.modifierFlags.contains(.control)) {
                case (.leftMouseDown, _, false):
                    fallthrough
                case (_, nil, _):
                    if !event.modifierFlags.contains(.command) {
                        self.didPressStatusItem(button)
                        
                        return nil
                    }

                case (_, let menu?, true):
                    fallthrough
                case (.rightMouseDown, let menu?, _):
//                    menu.popUp(positioning: nil, at: CGPoint(x: 0, y: button.bounds.maxY + 5), in: button)
                    return nil

                default:
                    break
                }
            } else {
                
            }

            return event
        }
    }
    
    private func didPressStatusItem(_ sender: NSStatusBarButton) {
        if window.isVisible {
            dismissWindow()
            
            return
        }
        
        // Tells the system to persist the menu bar in full screen mode.
        // must be before any activations take place
        DistributedNotificationCenter.default().post(name: .beginMenuTracking, object: nil)
        
        // Update the window frame, this resets every time
        setWindowFrame()
        
        isOpen.send(true)
        
        // Set the focus to the app
        window.makeKeyAndOrderFront(nil)
    }
    
    private func setButtonHighlighted(to highlight: Bool) {
        statusItem?.button?.highlight(highlight)
    }
    
    func setWindowFrame(size: CGSize? = nil, withAnimation: Bool = false) {
        guard let statusWindow = self.statusItem?.button?.window else {
            // If we don't know where the status item is, just place the window in the center.
            if let size {
                window.setFrame(NSRect(origin: window.frame.origin, size: size), display: true, animate: false)
            }
            
            window.center()
            
            return
        }
        
        var statusItemFrame = statusWindow.frame
        
//        Logger(subsystem: "nl.sakesalverda.ControlCenterExtra", category: "sizeUpdate").notice("Height of menu bar is \(statusItemFrame.size.height, privacy: .public)")
        
        statusItemFrame.origin.y -= 1
        
        // for fullsized statusbars, on MB pro 14" and 16" there is an additional pixel gap
        // this behaviour was checked in macOS versions:
        // 14.0
        // 14.1
        // 14.2
        // 14.3
        // 14.4
        if NSApplication.shared.mainMenu?.menuBarHeight ?? 37 >= 37 {
            statusItemFrame.origin.y -= 1
        }
        
        var newFrame = CGRect(origin: statusItemFrame.origin, size: size ?? window.frame.size)
        
        newFrame.origin.y -= newFrame.height
        
        switch alignment {
        case .left:
            // Note: Offset by window border size to align with highlighted button.
            newFrame.origin.x -= Metrics.windowBorderSize
        case .center:
            newFrame.origin.x += (statusItemFrame.width / 2) - (newFrame.width / 2)
        case .right:
            // Note: Offset by window border size to align with highlighted button.
            newFrame.origin.x += statusItemFrame.width - newFrame.width + Metrics.windowBorderSize
        }
        
        if let screen = NSScreen.main {
            if newFrame.maxX > screen.visibleFrame.maxX {
                switch (alignment, screenClippingBehaviour) {
                case (.left, .reverseAlignment):
                    newFrame.origin.x = statusItemFrame.maxX - newFrame.width + Metrics.windowBorderSize
                default:
                    newFrame.origin.x = screen.visibleFrame.maxX - newFrame.width - Metrics.windowBorderSize
                }
            }

            if newFrame.minX < screen.visibleFrame.minX {
                switch (alignment, screenClippingBehaviour) {
                case (.right, .reverseAlignment):
                    newFrame.origin.x = statusItemFrame.minX - Metrics.windowBorderSize

                    if newFrame.maxX > screen.visibleFrame.maxX {
                        fallthrough
                    }
                default:
                    newFrame.origin.x = screen.visibleFrame.minX + Metrics.windowBorderSize
                }
            }
        }
        
        guard newFrame != window.frame else {
            return
        }

        window.setFrame(newFrame, display: true, animate: withAnimation)
    }
    
    func dismissWindow(withAnimation: Bool = true) {
        // Tells the system to cancel persisting the menu bar in full screen mode.
        DistributedNotificationCenter.default().post(name: .endMenuTracking, object: nil)
        
        if withAnimation {
            // TODO: check in future versions if this works
            // window.animationBehavior = .utilityWindow results in a visual bug for NSVisualEffectView when animating out
            // the window is grayed during the build-in opacity animation (for both dark and light mode, although in light mode its less visible)
            // therefore we use a custom animation to fade the panel out
            window.animationBehavior = .none
        } else {
            window.animationBehavior = .none
        }
        
        NSAnimationContext.runAnimationGroup { context in
            if !withAnimation {
                context.duration = 0
            }
            
            window.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.isOpen.send(false)
            self?.window.orderOut(nil)
            self?.window.alphaValue = 1
            self?.setButtonHighlighted(to: false)
        }
    }
    
    
    // MARK: WindowDelegates
    
    func windowDidBecomeKey(_ notification: Notification) {
        globalEventMonitor?.start()
        
        setButtonHighlighted(to: true)
    }
    
    func windowDidResignKey(_ notification: Notification) {
        globalEventMonitor?.stop()
        
        let animate: Bool
        
        let mouseInStatusItem = NSMouseInRect(NSEvent.mouseLocation, statusItem?.button?.window?.frame ?? .zero, false)
        let mouseInWindow = NSMouseInRect(NSEvent.mouseLocation, window.frame, false)
        
        if let minY = statusItem?.button?.window?.frame.minY {
            // test if above the status bar
            if NSEvent.mouseLocation.y >= minY {
                if mouseInStatusItem {
                    animate = true
                } else {
                    animate = false
                }
            } else {
                if mouseInWindow {
                    animate = false // actually Apple does usually animate this, however, our app launches immediately
                } else {
                    animate = true
                }
            }
        } else {
            animate = true
        }
        
        dismissWindow(withAnimation: animate)
    }
}

internal extension Notification.Name {
//    static let beginMenuTracking = NSMenu.didBeginTrackingNotification
    static let beginMenuTracking = Notification.Name("com.apple.HIToolbox.beginMenuTrackingNotification")
    static let endMenuTracking = Notification.Name("com.apple.HIToolbox.endMenuTrackingNotification")
    
    static let test = NSMenu.didBeginTrackingNotification
    
}

/// Controls how the pop-up window is aligned relative to the menubar item.
public enum PopUpAlignment: Hashable {
    /// The pop-up window's left edge is aligned with the menubar item's left edge.
    case left

    /// The pop-up window is centred underneath the menubar item.
    case center

    /// The pop-up window's right edge is aligned with the menubar item's right edge.
    case right
}

/// Controls how the pop-up window's position is adapted to space constraints from encountering the left or right edges of the screen.
public enum ScreenClippingBehaviour: Hashable {
    /// If there isn't enough space to use the normal alignment, switch to its reverse (e.g. ``FluidMenuBarExtraPopUpAlignment/right`` instead of ``FluidMenuBarExtraPopUpAlignment/left``).  If this still isn't sufficient to resolve the problem, the behaviour falls back to ``hugEdge``.
    case reverseAlignment

    /// Nudge the pop-up window in from the edge just enough to make it fully visible.  This may mean an otherwise unnatural alignment of the pop-up window and the menubar item, not corresponding to any of the ``FluidMenuBarExtraPopUpAlignment`` options.
    case hugEdge
}

fileprivate enum Metrics {
    static let windowBorderSize: CGFloat = 2
}
