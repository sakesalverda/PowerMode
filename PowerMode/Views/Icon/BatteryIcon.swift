//
//  BatteryIcon.swift
//  PowerMode
//
//  Created by Sake Salverda on 13/04/2024.
//

import SwiftUI
import Vision
import CoreImage

struct MKSymbolShape: InsettableShape {
    var insetAmount = 0.0
    var systemName: String = ""
    var imgName: String = ""
    
    var trimmedImage: NSImage {
        let cfg = NSImage.SymbolConfiguration(pointSize: 256.0, weight: .regular)
        // get the symbol
        let img: NSImage
        if !systemName.isEmpty {
            img = NSImage(systemSymbolName: systemName, accessibilityDescription: nil)!.withSymbolConfiguration(cfg)!
        } else {
            img = NSImage(named: NSImage.Name(imgName))!
        }
        
        // we want to "strip" the bounding box empty space
        // get a cgRef from imgA
        guard let cgRef = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Could not get cgImage!")
        }
        // create imgB from the cgRef
        let imgB = NSImage(cgImage: cgRef, size: img.size)
        
        // now render it on a white background
        let resultImage = NSImage(size: imgB.size, flipped: false) { rect in
            NSColor.white.setFill()
            rect.fill()
            imgB.draw(in: rect)
            return true
        }
        
        return resultImage
    }
    
    func path(in rect: CGRect) -> Path {
        // cgPath returned from Vision will be in rect 0,0 1.0,1.0 coordinates
        //  so we want to scale the path to our view bounds
        
        let inputImage = self.trimmedImage
        guard let cgPath = detectVisionContours(from: inputImage) else { return Path() }
        let scW: CGFloat = (rect.width - CGFloat(insetAmount)) / cgPath.boundingBox.width
        let scH: CGFloat = (rect.height - CGFloat(insetAmount)) / cgPath.boundingBox.height
        
        // we need to invert the Y-coordinate space
        var transform = CGAffineTransform.identity
            .scaledBy(x: scW, y: -scH)
            .translatedBy(x: 0.0, y: -cgPath.boundingBox.height)
        
        if let imagePath = cgPath.copy(using: &transform) {
            return Path(imagePath)
        } else {
            return Path()
        }
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += Double(amount)
        return shape
    }
    
    func detectVisionContours(from sourceImage: NSImage) -> CGPath? {
        let inputImage = CIImage(cgImage: sourceImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
        let contourRequest = VNDetectContoursRequest()
        contourRequest.revision = VNDetectContourRequestRevision1
        contourRequest.contrastAdjustment = 2.0
        contourRequest.maximumImageDimension = 512
        
        let requestHandler = VNImageRequestHandler(ciImage: inputImage, options: [:])
        do {
            try requestHandler.perform([contourRequest])
            return contourRequest.results?.first?.normalizedPath
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
}

func img(strokeOffset: CGFloat, charging: Bool = false) -> NSImage {
    var xmlSVGImage = """
<?xml version="1.0" encoding="UTF-8"?> <!--Generator: Apple Native CoreSVG 232.5--> <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"        "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"> <svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="173.34" height="279.005" viewbox="-\(strokeOffset) -\(strokeOffset) \(173.34 + 2 * strokeOffset) \(279.005 + 2 * strokeOffset)">  <g>   <rect height="279.005" opacity="0" width="173.34" x="0" y="0"/>   <path d="M0 154.395C0 158.399 3.125 161.524 7.71484 161.524L79.2969 161.524L41.4062 264.356C37.1094 275.684 48.7305 281.543 56.1523 272.364L170.117 129.785C171.973 127.344 173.047 125.098 173.047 122.559C173.047 118.555 170.02 115.332 165.43 115.332L93.75 115.332L131.738 12.598C136.035 1.17218 124.414-4.6872 116.992 4.59015L3.02734 147.168C1.17188 149.61 0 151.856 0 154.395Z" fill="#000" stroke="#000" stroke-width="\(2 * strokeOffset)"/>  </g> </svg>
"""
    
    if !charging {
        xmlSVGImage = """
<?xml version="1.0" encoding="UTF-8"?> <!--Generator: Apple Native CoreSVG 232.5--> <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"        "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"> <svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="313.77" height="215.527" viewbox="-\(strokeOffset) -\(strokeOffset) \(313.77 + 2 * strokeOffset) \(215.527 + 2 * strokeOffset)">  <g>   <rect height="215.527" opacity="0" width="313.77" x="0" y="0"/>   <path d="M0 132.129C0 148.535 9.27734 157.715 25.9766 157.715L67.3828 157.715C84.9609 157.715 94.043 162.305 105.566 177.051C124.609 201.758 153.906 215.332 184.57 215.332L222.754 215.332C232.422 215.332 238.965 208.887 238.965 199.316L238.965 15.4297C238.965 6.25 232.422 0 222.754 0L184.57 0C153.906 0 124.609 13.5742 105.566 38.1836C94.043 53.0273 84.9609 57.7148 67.3828 57.7148L25.9766 57.7148C9.27734 57.7148 0 66.7969 0 83.2031ZM227.832 82.1289L295.605 82.1289C305.664 82.1289 313.77 74.0234 313.77 63.9648C313.77 53.9062 305.664 45.7031 295.605 45.7031L227.832 45.7031ZM227.832 169.629L295.605 169.629C305.664 169.629 313.77 161.523 313.77 151.465C313.77 141.309 305.664 133.203 295.605 133.203L227.832 133.203Z" fill="#000000" stroke="#000" stroke-width="\(2 * strokeOffset)"/>  </g> </svg>
"""
    }
    
    let svgData = xmlSVGImage.data(using: .utf8)!
    let svgImage = NSImage(data: svgData)
    
    return svgImage!
}

struct BatteryIcon: View {
    @Environment(AppState.self) private var appState
    
    var percentage: Double {
        Double(appState.batteryCurrentPercentage ?? 0) / 100
    }
    
    var mainSize: CGFloat = 18
    
    var isCharging: Bool {
        appState.isCharging
    }
    
    var isPlugged: Bool {
        appState.isUsingPowerAdapter
    }
    
    var isFullyCharged: Bool {
        appState.isFullyCharged
    }
    
    var bundle: Bundle? {
        Bundle(identifier: "com.apple.controlcenter") ?? Bundle.main
    }
    
    @Environment(\.isMenuPresented) var isMenuPresented
    @Environment(\.colorScheme) var currentColorScheme
    
    @Preference(\.currentEnergyModeStatusIcon) private var energyModeIndicator
    
    @Preference(\.displayBatteryPercentageInMenu) private var displayBatteryPercentage
    @Preference(\.displayBatteryPercentageCompact) private var batteryPercentageInline
    
    var inlineText: Bool {
        displayBatteryPercentage && batteryPercentageInline
    }
    
    var coloredColorScheme: AnyShapeStyle {
        if energyModeIndicator != .color {
            return AnyShapeStyle(.primary)
        }
        
//        if isCharging {
//            return AnyShapeStyle(.green)
//        } else {
        if percentage <= 0.2 && appState.isUsingBattery {
            if appState.currentEnergyMode == .low {
                return AnyShapeStyle(.yellow)
            } else {
                return AnyShapeStyle(.red)
            }
        } else {
            if appState.currentEnergyMode == .low {
                return AnyShapeStyle(.yellow)
            }
            
            if appState.currentEnergyMode == .high {
                return AnyShapeStyle(.blue)
            }
            
            return AnyShapeStyle(.primary)
        }
//        }
//        isCharging ? .green : percentage < 0.2 ? appState.batteryEnergyMode == .low ? .yellow : .red : nil
    }
    
    var body: some View {
        HStack(spacing: 1) {
            ZStack {
                ZStack(alignment: .leading) {
                    if inlineText {
                        RoundedRectangle(cornerRadius: 3)
                            .strokeBorder(.primary, lineWidth: 1)
                            .opacity(0.6)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .padding(1)
                        
                        Text(appState.batteryCurrentPercentage?.description ?? "?")
                            .blendMode(.destinationOut)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    } else {
                        RoundedRectangle(cornerRadius: 3)
                            .strokeBorder(.primary, lineWidth: 1)
                            .opacity(0.6)
    //                    Image("battery-outline", bundle: bundle)
    //                        .renderingMode(.template)
                        
                        GeometryReader { proxy in
                            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                                .frame(minWidth: 3, maxWidth: proxy.size.width * percentage)
                        }
                        .padding(2)
                        .foregroundStyle(coloredColorScheme)
                        .colorScheme(isMenuPresented ? .dark : currentColorScheme)
//                        .animation(.default, value: appState.currentEnergyMode)
//                        .animation(.default, value: appState.batteryCurrentPercentage)
                    }
                }
                .frame(width: 23, height: 12)
                
                if isPlugged && !inlineText {
                    if isCharging || (isFullyCharged && isPlugged) {
                        Image("battery-bolt-mask", bundle: bundle)
                            .blendMode(.destinationOut)
                        
                        Image("battery-bolt", bundle: bundle)
                            .renderingMode(.template)
                    } else {
                        Image("battery-plug-mask", bundle: bundle)
                            .blendMode(.destinationOut)
                        
                        Image("battery-plug", bundle: bundle)
                            .renderingMode(.template)
                    }
                }
            }
            .compositingGroup()
            
            if inlineText {
                Capsule()
                    .frame(width: 7, height: 6)
                    .frame(width: 2, height: 5, alignment: .trailing)
                    .clipped()
                    .opacity(0.6)
                    .offset(x: -1)
            } else {
                Capsule()
                    .frame(width: 5, height: 5)
                    .frame(width: 1.5, height: 4, alignment: .trailing)
                    .clipped()
                    .opacity(0.6)
            }
            
//            Image("battery-cap", bundle: bundle)
//                .renderingMode(.template)
        }
    }
    
    var swift_body: some View {
        HStack(spacing: 3) {
            ZStack {
                let leftX: CGFloat = 44 / 190 * mainSize
                let width: CGFloat = 200 / 190 * mainSize
                
                Image(systemName: "battery.0percent")
                    .foregroundStyle(.secondary)
                
                Image(systemName: "battery.100percent")
                    .foregroundStyle(percentage <= 0.2 ? .primary : .primary, .clear)
                    .mask { GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 13 / 190 * mainSize)
                            .frame(width: leftX + width * CGFloat(percentage), height: 78 / 190 * mainSize)
                            .offset(y: 36 / 190 * mainSize)
                    }}
                
                if isPlugged {
                    ZStack {
                        let strokeOffset: CGFloat = 19
                        let width: CGFloat = mainSize * 0.4
                        
                        Image(nsImage: img(strokeOffset: strokeOffset, charging: isCharging))
                            .resizable()
                            .scaledToFit()
                            .frame(width: width + 1.7 * strokeOffset / 190 * mainSize)
                            .conditional(!isCharging) {
                                $0
                                .scaleEffect(1.39)
                                .rotationEffect(.degrees(-90))
                            }
                            .blendMode(.destinationOut)
                        
                        if isCharging {
                            Image(systemName: "bolt.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: width)
                        } else {
                            Image(systemName: isCharging ? "bolt.fill " : "powerplug.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: width)
                                .scaleEffect(1.59)
                                .rotationEffect(.degrees(-90))
                        }
                    }
                    .offset(x: -10 / 190 * mainSize)
                }
            }
            .drawingGroup()
            .compositingGroup()
            .font(.system(size: mainSize))
            .fontWeight(.light)
        }
    }
}

#Preview {
    BatteryIcon()
        .padding()
        .environment(AppState.preview)
}
