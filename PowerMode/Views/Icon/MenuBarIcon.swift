//
//  MenuBarIcon.swift
//  PowerMode
//
//  Created by Sake Salverda on 04/03/2024.
//

import SwiftUI
import Combine
import ControlCenterExtra

let statusBarImage = NSImage(systemSymbolName: "bolt.horizontal.fill", accessibilityDescription: nil)!.withSymbolConfiguration(.init(pointSize: 12, weight: .regular))!

// this way we make use of the observation framework, as getStatusBarImage uses the current icon design
extension AppState {
    var statusBarImage: NSImage {
        getStatusBarImage(appState: self)
    }
}

func getStatusBarImage(appState: AppState) -> NSImage {
    @Preference(\.currentEnergyModeStatusIcon) var useImageIndicator
    
    let currentMode = appState.isUsingBattery ? appState.internalBatteryEnergyMode : appState.internalAdapterEnergyMode
    
    switch useImageIndicator {
    case .bar:
        if let currentMode {
            return statusBarImageLine(for: currentMode)
        }
    case .icon:
        if let currentMode {
            return statusBarImageIcon(for: currentMode, highlight: true)
        }
    default: break
    }
    
    return statusBarImage
}

struct MenuBarIconPicker: View {
    @Environment(AppState.self) private var appState
    
    @Preference(\.currentEnergyModeStatusIcon) private var currentEnergyModeStatusIcon
    
    @Preference(\.menuIconVariant) private var menuIconVariant
    
    var previewEnergyMode: EnergyMode {
        // we use lower power mode as this is available on all user devices
        // and .automatic doesn't have any visualisation on the bar style
        .low
//        appState.currentEnergyMode ?? .automatic
    }
    
    @Environment(\.verticalSizeClass) private var sizeClass
    
    var columns: [GridItem] {
        let g = GridItem(.flexible(), spacing: 16)
        
        if menuIconVariant == .status {
            return Array(repeating: g, count: 3)
        } else {
           return Array(repeating: g, count: 3)
        }
    }
    
    var body: some View {
        SettingsPicker {
            LazyVGrid(columns: columns) {
                SettingsPickerOption {
                    .init {
                        currentEnergyModeStatusIcon == .none
                    } set: { _ in
                        withAnimation {
                            currentEnergyModeStatusIcon = .none
                        }
                    }
                } content: {
                    MenuBarImage.Base(isPreview: true)
                } label: {
                    Text("None")
                        .fixedSize()
                    //                    Text("Default")
                    //                        .font(.footnote)
                    //                        .foregroundStyle(.tertiary)
                }
                
                SettingsPickerOption {
                    .init {
                        currentEnergyModeStatusIcon == .icon
                    } set: { _ in
                        withAnimation {
                            currentEnergyModeStatusIcon = .icon
                        }
                    }
                } content: {
                    MenuBarImage.Icon(isPreview: true, for: previewEnergyMode)
                } label: {
                    Text("Icon")
                        .fixedSize()
                }
                
                SettingsPickerOption {
                    .init {
                        currentEnergyModeStatusIcon == .bar
                    } set: { _ in
                        withAnimation {
                            currentEnergyModeStatusIcon = .bar
                        }
                    }
                } content: {
                    MenuBarImage.Line(isPreview: true, for: previewEnergyMode)
                } label: {
                    Text("Bar")
                        .fixedSize()
                }
                
                if menuIconVariant == .status {
//                    Color.clear
//
//                    Color.clear
                    
                    SettingsPickerOption {
                        .init {
                            currentEnergyModeStatusIcon == .color
                        } set: { _ in
                            withAnimation {
                                currentEnergyModeStatusIcon = .color
                            }
                        }
                    } content: {
                        ZStack {
                            Group {
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(.primary, lineWidth: 1)
                                    .opacity(0.6)
                                    .opacity(0.33)
                                
                                GeometryReader { proxy in
                                    RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                                        .frame(minWidth: 3, maxWidth: proxy.size.width * 0.8)
                                        .foregroundStyle(.yellow)
                                }
                                .padding(2)
                            }
                            .frame(width: 23, height: 12)
                        }
                    } label: {
                        Text("Color")
                            .fixedSize()
                    }
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
//                    .transition(.reveal(from: .top, with: -3).combined(with: .scale(scale: 0.7)))
                    //                .transition(.scale(scale: 0.7).combined(with: .reveal(from: .trailing)))
                }
            }
            .fixedSize()
        }
        .controlSize(.small)
        .animation(.default, value: menuIconVariant)
        .animation(nil, value: currentEnergyModeStatusIcon)
    }
}

fileprivate func statusBarImageLine(for energyMode: EnergyMode) -> NSImage {
    let image = statusBarImage
    
    let icon = NSImage(systemSymbolName: "minus", accessibilityDescription: nil)!.withSymbolConfiguration(.init(pointSize: 14, weight: .medium))! // 10
    
    // setup sizes
    let imageSize = image.size
    let iconSize = icon.size
    
    // determine final output image dimensions
    let newWidth: CGFloat, newHeight: CGFloat
    
    newWidth = imageSize.width
    newHeight = max(imageSize.height, iconSize.height) + 8
    
    let newSize: CGSize = .init(width: newWidth, height: newHeight)
    
    // create the new image
    let newImage = NSImage(size: newSize)
    
    // origin at which to place the image
    let imageOrigin: CGPoint = .init(x: 0, y: (newSize.height - imageSize.height) / 2)
    
    var origin: CGFloat
    
    switch energyMode {
    case .automatic:
        origin = (newSize.height - iconSize.height) / 2
    case .low:
        origin = 0
    case .high:
        origin = newSize.height - iconSize.height
    }
    
    let iconOrigin: CGPoint = .init(x: (imageSize.width - iconSize.width) / 2, y: origin)
    
    newImage.lockFocus()
    
    // draw the image
    image.draw(at: imageOrigin, from: .zero, operation: .copy, fraction: 1.0)
    
    // draw the icon
    // we don't draw the line at automatic as it would not be visible anyway
    if energyMode != .automatic {
        icon.draw(at: iconOrigin, from: .zero, operation: .overlay, fraction: 0.75)
    }
    
    newImage.unlockFocus()
    
    newImage.isTemplate = true
    
    return newImage
}

fileprivate func statusBarImageIcon(for energyMode: EnergyMode, highlight hasBackground: Bool = false) -> NSImage {
    let iconSymbolName: String = energyMode.systemImage
    
    var iconFontPointSize: CGFloat {
        if hasBackground {
            8 * (iconSymbolName.contains("battery") ? 0.9 : 1)
        } else {
            10
        }
    }
    
    var iconAlphaComponent: CGFloat {
        if hasBackground {
            1
        } else {
            0.5
        }
    }
    
    var iconGap: CGFloat {
        hasBackground ? 2 : 0
    }
    
    let image = statusBarImage
    
    let iconFontConfiguration: NSImage.SymbolConfiguration = .init(pointSize: iconFontPointSize, weight: .medium)
//            .applying(.init(paletteColors: [.white]))
    
    let icon = NSImage(systemSymbolName: iconSymbolName, accessibilityDescription: nil)!.withSymbolConfiguration(iconFontConfiguration)! // 10
    
    // diameter of the circle
    let circleDiameter: CGFloat = 13
    
    // gap between image and current energy mode icon
    let gap: CGFloat = iconGap
    
    // setup sizes
    let imageSize = image.size
    let iconSize = icon.size
    let circleSize: CGSize = .init(width: circleDiameter, height: circleDiameter)
    
    // determine final output image dimensions
    let newWidth: CGFloat, newHeight: CGFloat
    if hasBackground {
        newWidth = imageSize.width + max(iconSize.width, circleSize.width) + gap
        newHeight = max(imageSize.height, iconSize.height, circleSize.height)
    } else {
        newWidth = imageSize.width + iconSize.width + gap
        newHeight = max(imageSize.height, iconSize.height)
    }
    
    let newSize: CGSize = .init(width: newWidth, height: newHeight)
    
    // create the new image
    let newImage = NSImage(size: newSize)
    
    // origin at which to place the image
    let imageOrigin: CGPoint = .init(x: 0, y: (newSize.height - imageSize.height) / 2)
    
    let modeWidth: CGFloat = max(iconSize.width, circleSize.width)
    
    // origin at which to place the icon
//        let iconOffset: CGFloat = (circleSize.width - iconSize.width) / 2
    
    let iconOrigin: CGPoint = .init(x: imageSize.width + gap + (modeWidth - iconSize.width) / 2, y: (newSize.height - iconSize.height) / 2)
    
    let circleOrigin: CGPoint = .init(x: imageSize.width + gap + (modeWidth - circleSize.width) / 2, y: (newSize.height - circleSize.height) / 2)
    
    newImage.lockFocus()
    
    // draw the image
    image.draw(at: imageOrigin, from: .zero, operation: .copy, fraction: 1.0)
    
    // draw the circle
    if hasBackground {
        NSColor.black.withAlphaComponent(0.2).setFill()
        
        let circleRect = NSRect(origin: circleOrigin, size: circleSize)
        NSBezierPath(ovalIn: circleRect).fill()
    }
    
    // draw the icon
    icon.draw(at: iconOrigin, from: .zero, operation: .screen, fraction: iconAlphaComponent)
    
    newImage.unlockFocus()
    
    newImage.isTemplate = true
    
    return newImage
}

fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let newValue = nextValue()
        
        if newValue != .zero {
            value = newValue
        }
    }
}

struct MenuBarImage: View {
    @Environment(AppState.self) private var appState
    
    @Preference(\.menuIconVariant) private var mainIcon
    @Preference(\.currentEnergyModeStatusIcon) private var energyModeIcon
    
    var body: some View {
        Combined(mainIconVariant: mainIcon, iconVariant: energyModeIcon, currentEnergyMode: appState.currentEnergyMode)
            .equatable()
    }
    
//    var body2: some View {
//        Group {
//            switch icon {
//            case .none:
//                Base()
//            case .bar:
//                Line(for: appState.currentEnergyMode, didReadOnce: appState.hasFirstRead)
//            case .icon:
//                Icon(for: appState.currentEnergyMode, didReadOnce: appState.hasFirstRead)
//            }
//        }
//        .offset(x: 0, y: -1)
//    }
    
    struct Base: View {
        var isPreview: Bool = false
        
        var body: some View {
            Image(systemName: "bolt.horizontal.fill")
                .font(.system(size: 12))
                .opacity(isPreview ? 0.33 : 1)
        }
    }
    
    struct Combined: View, Equatable {
        static func == (lhs: MenuBarImage.Combined, rhs: MenuBarImage.Combined) -> Bool {
            lhs.currentEnergyMode == rhs.currentEnergyMode && lhs.iconVariant == rhs.iconVariant
        }
        
        @Environment(AppState.self) private var appState
        
        private var iconVariant: MenuBarEnergyModeIndicatorVariant
        private var mainIconVariant: MenuBarIconVariant
        
        private var currentEnergyMode: EnergyMode?
        
        private var isSmall: Bool {
            animationEnergyMode == .low
        }
        
        private var mainIcon: MenuBarIconVariant {
            mainIconVariant
        }
        private var energyModeIcon: MenuBarEnergyModeIndicatorVariant { iconVariant }
        
        init(mainIconVariant: MenuBarIconVariant = .default, iconVariant: MenuBarEnergyModeIndicatorVariant, currentEnergyMode: EnergyMode?) {
            self.mainIconVariant = mainIconVariant
            self.iconVariant = iconVariant
            self.currentEnergyMode = currentEnergyMode
            self.animationEnergyMode = currentEnergyMode
        }
        
        @State private var animationEnergyMode: EnergyMode?
        @State private var animationPreviousEnergyMode: EnergyMode?
        
        @State private var animationTopDelay: Double = 0
        @State private var animationBottomDelay: Double = 0
        
        @ViewBuilder private var line: some View {
            Capsule()
                .frame(width: 12, height: 1.5)
                .opacity(0.75)
        }
        
        @ViewBuilder private func line(mode: EnergyMode?) -> some View {
            ZStack {
                if animationEnergyMode == mode {
                    line
                        .offset(y: (mode == .high ? -1 : 1) * 7)
                    
                        .conditional(menuIconVariant == .status) {
                            $0.offset(y: (mode == .high ? -1 : 1) * 2)
                            .offset(x: -1.5)
                        }
                    
                        .conditional(menuIconVariant == .percentage) {
                            $0.offset(y: (mode == .high ? -1 : 1) * 1)
                        }
                    
                        .transition(.opacity.combined(with: .offset(y: (mode == .high ? -1 : 1) * 1.5)))
                }
            }
            .transaction { transaction in
                if mode == .high {
                    transaction.animation = transaction.animation?.delay(animationTopDelay)
                } else if mode == .low {
                    transaction.animation = transaction.animation?.delay(animationBottomDelay)
                }
            }
        }
        
        private let iconSpacing: CGFloat = 2
        private let iconSize: CGSize = .init(width: 13, height: 13)
        private let iconInset: CGSize = .init(width: 3, height: 0)
        
        var percentageText: String {
            if let percentage = appState.batteryCurrentPercentage {
                "\(percentage)"
            } else { "?" }
        }
        
//        @Preference(\.hideMainIcon) var hideMainIcon
        
//        @Preference(\.useBatteryIcon) var useBatteryAsIcon
        
        @Preference(\.displayBatteryPercentageCompact) var inlineBatteryPercentage
        
        @Preference(\.displayBatteryPercentageInMenu) var displayBatteryPercentage
        
        @Preference(\.menuIconVariant) var menuIconVariant
        
        var body: some View {
            HStack(spacing: iconSpacing) {
                if menuIconVariant != .percentage {
                    if displayBatteryPercentage && !inlineBatteryPercentage {
                        Text(percentageText + "%")
                            .font(.subheadline)
                            .padding(.trailing, 1)
                    }
                }
                
                HStack(spacing: 0) {
                    ZStack {
                        switch menuIconVariant {
                        case .default:
                            Base()
                        case .status:
                            BatteryIcon()
                        case .percentage:
                            Text(percentageText)
                                .font(.subheadline)
                        }
                        //                        .background { GeometryReader { proxy in
                        //                            Color.clear
                        //                                .onAppear {
                        //                                    print(proxy.size.width)
                        //                                }
                        //                        }}
                        
                        if energyModeIcon == .bar {
                            line(mode: .high)
                            
                            line(mode: .low)
                        }
                    }
                    
                    if menuIconVariant == .percentage {
                        Text("%")
                    }
                }
                // this forces the lines to move with the icon when appearing/disappearing
                .geometryGroup()
                
//                ZStack {
                    if energyModeIcon == .icon {
                        ZStack {
                            Circle()
                                .opacity(0.2)
                            
                            Group {
                                Image(systemName: animationEnergyMode?.systemImage ?? "questionmark")
                                    .font(.system(size: isSmall ? 7.2 : 8, weight: .medium))
                                
                                // energy mode
                                    .id(animationEnergyMode?.systemImage ?? "none")
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .frame(size: iconSize)
                        .transition(.scale(0.33).combined(with: .opacity).combined(with: .offset(
                            x: -(iconSpacing + iconSize.width - 2*iconInset.width))
                        ))
                    }
//                }
//                .transaction(value: icon) { transaction in
//                    if icon == .icon {
//                        transaction.animation = transaction.animation?.delay(0.2)
//                    }
//                }
            }
            .padding(.horizontal, energyModeIcon == .icon ? -iconInset.width : 0)
            .geometryGroup()
            .animation(nil, value: mainIconVariant)
            .animation(.default, value: energyModeIcon)
            .animation(animationPreviousEnergyMode == nil ? nil : .default, value: animationEnergyMode)
            .onChange(of: currentEnergyMode) { previous, new in
                animationEnergyMode = new
                animationPreviousEnergyMode = previous
                
                var newTopDelay: Double = 0
                var newBottomDelay: Double = 0
                
                defer {
                    animationTopDelay = newTopDelay
                    animationBottomDelay = newBottomDelay
                }
                
                if previous == .automatic || previous == nil || previous == new { return }
                
                if new == .high { newTopDelay = 0.5 }
                if new == .low { newBottomDelay = 0.5 }
            }
        }
    }
    
    struct Icon: View {
        var isPreview: Bool = false
        
        private var currentEnergyMode: EnergyMode?
        private var hasReadModesOnce: Bool
        
        init(for energyMode: EnergyMode?, didReadOnce: Bool = true) {
            self.currentEnergyMode = energyMode
            self.hasReadModesOnce = didReadOnce
        }
        
        init(isPreview: Bool, for energyMode: EnergyMode?, didReadOnce: Bool = true) {
            self.isPreview = isPreview
            self.currentEnergyMode = energyMode
            self.hasReadModesOnce = didReadOnce
        }
        
        private var isSmall: Bool {
            currentEnergyMode == .low
        }
        
        var body: some View {
            HStack(spacing: 2) {
                Base(isPreview: isPreview)
                
                ZStack {
                    Circle()
                        .frame(width: 13)
                        .opacity(0.2)
//                        .foregroundStyle(.blue)
                    
                    Group {
                        /*mage(nsImage: NSImage(systemSymbolName: currentEnergyMode.systemImage, accessibilityDescription: nil)!.withSymbolConfiguration(.init(pointSize: 8, weight: .medium))!)*/
                        
                        Image(systemName: currentEnergyMode?.systemImage ?? "questionmark")
                            .id(currentEnergyMode?.systemImage ?? "none")
                            .font(.system(size: isSmall ? 7.2 : 8, weight: .medium))
//                            .transition(.opacity)
//                            .transition(.scale(scale: 0.66).combined(with: .opacity))
                            //                            .foregroundStyle(.white)
                    }
                }
                // otherwise there is a small animation from questionmark to thingy
                .conditional(hasReadModesOnce && !isPreview) {
                    $0.animation(.default, value: currentEnergyMode)
                }
            }
        }
    }
    
    struct Line: View {
        var isPreview: Bool = false
        
        private var currentEnergyMode: EnergyMode?
        private var hasReadModesOnce: Bool
        
        init(for energyMode: EnergyMode?, didReadOnce: Bool = true) {
            self.animationEnergyMode = energyMode // if we don't set it here, it will animate initially
            self.currentEnergyMode = energyMode
            self.hasReadModesOnce = didReadOnce
        }
        
        init(isPreview: Bool, for energyMode: EnergyMode?, didReadOnce: Bool = true) {
            self.isPreview = isPreview
            self.animationEnergyMode = energyMode // if we don't set it here, it will animate initially
            self.currentEnergyMode = energyMode
            self.hasReadModesOnce = didReadOnce
        }
        
        @ViewBuilder
        var line: some View {
            Capsule()
                .frame(width: 12, height: 1.5)
                .opacity(isPreview ? 1 : 0.75)
        }
        
        @State var animationEnergyMode: EnergyMode?
        @State var animationTopDelay: Double = 0
        @State var animationBottomDelay: Double = 0
        
        var body: some View {
            ZStack {
                Base(isPreview: isPreview)
                
                // high bar
                line
                    .offset(y: animationEnergyMode == .high ? 0 : -1.5)
                    .offset(y: -7)
                    .opacity(animationEnergyMode == .high ? 1 : 0)
                    .animation(.default.delay(animationTopDelay), value: animationEnergyMode)
                
                // low bar
                line
                    .offset(y: animationEnergyMode == .low ? 0 : 1.5)
                    .offset(y: 7)
                    .opacity(animationEnergyMode == .low ? 1 : 0)
                    .animation(.default.delay(animationBottomDelay), value: animationEnergyMode)
                    .foregroundStyle(.secondary)
            }
            .onChange(of: currentEnergyMode, initial: true) { previous, new in
                if isPreview { return }
                
                animationEnergyMode = new
                
                var newTopDelay: Double = 0
                var newBottomDelay: Double = 0
                
                defer {
                    animationTopDelay = newTopDelay
                    animationBottomDelay = newBottomDelay
                }
                
                if previous == .automatic || previous == nil || previous == new { return }
                
                if new == .high { newTopDelay = 0.5 }
                if new == .low { newBottomDelay = 0.5 }
            }
        }
    }
}

#Preview("Icon Designs") {
    VStack(spacing: 20) {
        HStack {
            ForEach(EnergyMode.allCases, id: \.self) { mode in
                Image(nsImage: statusBarImageIcon(for: mode, highlight: false))
            }
        }
        
        VStack {
            HStack {
                Text("image")
                    .frame(width: 40)
                
                ForEach(EnergyMode.allCases, id: \.self) { mode in
                    Image(nsImage: statusBarImageIcon(for: mode, highlight: true))
                }
            }
            
            HStack {
                Text("swift")
                    .frame(width: 40)
                
                ForEach(EnergyMode.allCases, id: \.self) { mode in
                    MenuBarImage.Icon(for: mode)
//                        .border(Color.red)
                }
            }
        }
        
        VStack {
            HStack {
                Text("image")
                    .frame(width: 40)
                
                ForEach(EnergyMode.allCases, id: \.self) { mode in
                    Image(nsImage: statusBarImageLine(for: mode))
                }
            }
            
            HStack {
                Text("swift")
                    .frame(width: 40)
                
                ForEach(EnergyMode.allCases, id: \.self) { mode in
                    MenuBarImage.Line(for: mode)
//                        .border(Color.red)
                }
            }
        }
    }
    .padding()
}

fileprivate struct PreviewTest: View {
    @State var mode: EnergyMode? = nil
    @State var icon: MenuBarEnergyModeIndicatorVariant = .icon
    
    @State var frame: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 20) {
            MenuBarImage.Combined(iconVariant: icon, currentEnergyMode: mode)
                .background { GeometryReader { proxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: proxy.size)
                }}
                .onPreferenceChange(SizePreferenceKey.self) { value in
                    print(value)
                    withAnimation {
                        frame = value
                    }
                }
                .frame(size: frame, alignment: .trailing)
                .border(.red)
                .frame(width: 200, alignment: .trailing)
            
            HStack {
                HStack {
                    Button {
                        icon = .none
                    } label: { Text("None") }
                    
                    Button {
                        icon = .icon
                    } label: { Text("Icon") }
                    
                    Button {
                        icon = .bar
                    } label: { Text("Bar") }
                }
                VStack {
                    Button {
                        mode = .high
                    } label: { Text("High") }
                    
                    Button {
                        mode = .automatic
                    } label: { Text("Auto") }
                    
                    Button {
                        mode = .low
                    } label: { Text("Low") }
                }
            }
            .onAppear {
                Task {
                    mode = .high
                }
            }
        }
        .padding()
    }
}

#Preview("Animations") {
    PreviewTest()
}

#Preview("Picker") {
    SettingsPreview {
        HStack {
            Spacer()
            
            
            
            VStack(alignment: .trailing) {
                MenuBarIconPicker()
//
//                MenuBarIconPicker()
//                    .environment(\.verticalSizeClass, .compact)
            }
        }
        .padding()
    }
    .environment(AppState.preview)
}
