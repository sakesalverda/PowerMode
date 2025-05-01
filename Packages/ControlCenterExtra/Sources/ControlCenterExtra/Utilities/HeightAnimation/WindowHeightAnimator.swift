//
//  WindowHeightAnimator.swift
//  PowerMode
//
//  Created by Sake Salverda on 10/01/2024.
//

import AppKit

extension WindowHeightAnimator {
    func restoreContentSize() {
        if lastContentSize == .zero {
            print("DID EMPTY RESTORE")
            didEmptyRestore = true
        } else {
            updateContentSize(lastContentSize, animated: false)
        }
    }
    
    func updateContentSize(_ contentSize: CGSize, animated: Bool = true) {
        if contentSize == .zero {
            return
        }
        
        var useAnimation = animated
        
        if didEmptyRestore {
            useAnimation = false
            didEmptyRestore = false
        }
        
        self.lastContentSize = contentSize
        
        let newWidth = contentSize.width
        let newHeight = contentSize.height
        
        if let contentWindowFrame = contentWindowFrame,
           let contentSizeUpdater = contentSizeUpdater,
           let frame = contentWindowFrame() {
            var nextFrame = frame
            
            let deltaX = newWidth - nextFrame.size.width
            let deltaY = newHeight - nextFrame.size.height
            
            nextFrame.origin.x -= deltaX
            nextFrame.origin.y -= deltaY
            
            nextFrame.size.width += deltaX
            nextFrame.size.height += deltaY
            
//            if useAnimation {
                NSAnimationContext.runAnimationGroup { context in
                    if useAnimation {
                        context.duration = 0.22
                        context.timingFunction = CAMediaTimingFunction(name: .default)
                    } else {
                        context.duration = 0.0001
                    }
                    
                    contentSizeUpdater(nextFrame)
                }
//            } else {
//                contentSizeUpdater(nextFrame)
//            }
        }
    }
}

@Observable
class WindowHeightAnimator {
    private var didEmptyRestore: Bool = false
    
//    @ObservationIgnored var isUpdatingHeightFromAltKey: Bool = false
//    var wrappedAnimation: Bool = false
    
//    @ObservationIgnored private var internalAnimationCounter = 0
    
//    @ObservationIgnored private var laggedAnimationCounter = 0
    
    @ObservationIgnored private var lastContentSize: CGSize = .zero
    
    @ObservationIgnored var contentSizeUpdater: Optional<(CGRect) -> Void> = nil
    @ObservationIgnored var contentWindowFrame: Optional<() -> CGRect?> = nil
    
//    @ObservationIgnored var wrappedAnimation: Bool {
//        get {
//            internalAnimationCounter > 0
//        }
//        set {
//            if newValue == true {
//                internalAnimationCounter = 1
//                laggedAnimationCounter = 0
//                
//                return
//            } else {
//                // determined by experiment
//                let threshold = 2
//                
//                if newValue == false && laggedAnimationCounter < threshold {
//                    laggedAnimationCounter += 1
//                    
//                    return
//                }
//                
//                internalAnimationCounter = 0
//                laggedAnimationCounter = 0
//            }
//        }
//    }
}
