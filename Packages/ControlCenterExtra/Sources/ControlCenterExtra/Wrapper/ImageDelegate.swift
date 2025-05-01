//
//  File.swift
//  
//
//  Created by Sake Salverda on 25/03/2024.
//

import SwiftUI
import AppKit
import Combine

@Observable
class ImageDelegateIsPresentedDelegate {
    var isPresented: Bool = false
    
    var cancellable: AnyCancellable? = nil
}

@Observable
class ControlCenterDynamicImageDelegate<Content: View> {
    @ObservationIgnored
    private var hostingView: NSHostingView<ModifiedContent<Content, SizeTrackedIconModifier>>
    
    let menuDelegate: ImageDelegateIsPresentedDelegate = .init()
    
    @ObservationIgnored
    var statusItem: NSStatusItem? = nil {
        didSet {
//            statusItem?.button?.image = emptyImagePlaceholder(width: hostingView.frame.width, height: hostingView.frame.height)
            statusItem?.button?.frame = hostingView.frame
            statusItem?.button?.addSubview(hostingView)
        }
    }
    
    @ObservationIgnored
    private var sizePassthrough = PassthroughSubject<(CGSize, Bool), Never>()
    @ObservationIgnored
    private var sizeCancellable: AnyCancellable?
    
    @ObservationIgnored
    private var isInitialFrame: Bool = true
    
    deinit {
        sizeCancellable?.cancel()
    }
    
    @ObservationIgnored
    private(set) var boundingFrame: NSRect? = nil
    
    private(set) var delayedBoundingFrame: NSRect? = nil
    
    func triggerResize() {
//        statusItem?.button?.image = emptyImagePlaceholder(width: hostingView.frame.width, height: hostingView.frame.height)
//        hostingView.removeFromSuperviewWithoutNeedingDisplay()
//        statusItem?.button?.addSubview(hostingView)
        
        if let boundingFrame {
            statusItem?.button?.setFrameSize(boundingFrame.size)
            statusItem?.button?.setFrameOrigin(.zero)
        }
    }
    
    public init(statusItem: NSStatusItem? = nil, label: () -> Content) {
        self.statusItem = statusItem
        
        // 1 setup hosting view
        let hostingView = NSHostingView(rootView: label().modifier(SizeTrackedIconModifier(menuDelegate: menuDelegate, sizePassthrough: sizePassthrough)))
        
        // 2 setup hosting view frame
        hostingView.frame = NSRect(x: 0, y: 0, width: 80, height: 24)
        
        // 3 setup statusitem button
        statusItem?.button?.addSubview(hostingView)
        statusItem?.button?.setFrameSize(hostingView.frame.size)
        statusItem?.button?.setFrameOrigin(.zero)
        
        // 4
        self.hostingView = hostingView
        
        // 5 setup size tracker
        sizeCancellable = sizePassthrough.sink { [weak self] size, animation in
            let frame = NSRect(origin: .zero, size: .init(width: size.width, height: 24))
            
            NSAnimationContext.runAnimationGroup { context in
                if self?.isInitialFrame == true || !animation {
                    context.duration = 0
                } else {
                    context.duration = 0.35
                    context.timingFunction = .init(name: .default)
                }
                
                self?.boundingFrame = frame
                self?.hostingView.animator().setFrameSize(frame.size)
                self?.statusItem?.button?.animator().setFrameSize(frame.size)
            } completionHandler: {
                self?.delayedBoundingFrame = frame
            }
            
            self?.isInitialFrame = false
        }
    }
}
