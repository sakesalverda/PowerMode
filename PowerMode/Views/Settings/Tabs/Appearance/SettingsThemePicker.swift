//
//  SettingsLayout.swift
//  PowerMode
//
//  Created by Sake Salverda on 10/12/2023.
//

import SwiftUI

struct LayoutPreviewRow<S>: View where S: ShapeStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    var item: Int
    var numItems: Int
    
    private var useAnimation: Bool {
        isEnabled
    }
    
    @Preference(\.useModeInLabel) private var useModeInLabel
    
    var highlight: S
    
    init(item: Int, numItems: Int, highlight: S = .tint) {
        self.item = item
        self.numItems = numItems
        self.highlight = highlight
    }
    
    let width: CGFloat = 9
    
    private struct AnimationProperties {
        var opacity: [Double] = [1, 0, 0]
    }
    
    var lengthMultiplier: CGFloat {
        let standard: CGFloat = 3
        
        if useModeInLabel {
            return standard + 1.5
        }
        
        return standard
    }
    
    @State private var cachedState: AnimationProperties? = nil
    
    private func getForState(transitionState state: AnimationProperties) -> some View {
        HStack(spacing: 4) {
            ZStack {
                let circle = Circle()
                    .frame(width: width, height: width)
                
                circle
                    .foregroundStyle(highlight)
                    .opacity(state.opacity[item])
                circle
                    .foregroundStyle(.quaternary)
                    .opacity(1 - state.opacity[item])
            }
                
            ZStack {
                let shape = RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .frame(width: width * lengthMultiplier, height: width - 4)
                    .animation(nil, value: lengthMultiplier)
                
                shape
                    .foregroundStyle(.tertiary)
                    .opacity(state.opacity[item])
                shape
                    .foregroundStyle(.quaternary)
                    .opacity(1 - state.opacity[item])
            }
            
//            Spacer(minLength: 0)
        }
    }
    
    var body: some View {
        if !isEnabled {
            getForState(transitionState: .init())
        } else if isEnabled {
            KeyframeAnimator(initialValue: AnimationProperties(), repeating: true) { transitionState in
                getForState(transitionState: transitionState)
            } keyframes: { _ in
                let holdDuration: Double = 1.5
                let resetDuration: Double = 0.5
                let easeDuration: Double = 0.75
                
                let multFactorItem0 = numItems == 3
                
                //            if item == 1 {
                // conditionals are at the point of making this code not supported
                KeyframeTrack(\.opacity[0]) {
                    // hold
                    MoveKeyframe(1)
                    LinearKeyframe(1, duration: holdDuration)
                    
                    // animate
                    LinearKeyframe(0, duration: easeDuration, timingCurve: .circularEaseInOut)
                    
                    // hidden
                    // > high power mode IS visible
                    LinearKeyframe(0, duration: (multFactorItem0 ? 2 : 1) * (easeDuration + holdDuration) + resetDuration)
                    MoveKeyframe(0)
                    // > high power mode IS NOT visible
                    // LinearKeyframe(0, duration: 1*easeDuration + 1*holdDuration + resetDuration)
                    
                    // animate
                    LinearKeyframe(1, duration: easeDuration, timingCurve: .circularEaseInOut)
                }
                
                KeyframeTrack(\.opacity[1]) {
                    // hidden
                    MoveKeyframe(0)
                    LinearKeyframe(0, duration: holdDuration)
                    
                    // animate
                    LinearKeyframe(1, duration: easeDuration, timingCurve: .circularEaseInOut)
                    LinearKeyframe(1, duration: holdDuration)
                    LinearKeyframe(0, duration: easeDuration, timingCurve: .circularEaseInOut)
                    
                    // hidden
                }
                
                KeyframeTrack(\.opacity[2]) {
                    // hidden
                    MoveKeyframe(0)
                    LinearKeyframe(0, duration: 2*holdDuration + easeDuration)
                    
                    // animate
                    LinearKeyframe(1, duration: easeDuration, timingCurve: .circularEaseInOut)
                    LinearKeyframe(1, duration: holdDuration)
                    LinearKeyframe(0, duration: easeDuration, timingCurve: .circularEaseInOut)
                    
                    // hidden
                }
            }
        }
    }
}

struct SettingsThemePicker: View {
    @Environment(AppState.self) private var appState
    
    @Preference(\.useStaticHighlightColor) private var useStaticHighlightColor
    
    private var items: Int {
        appState.device.isHighPowerModeCapableDevice ? 3 : 2
    }
    
    private var colors: [Color] {
        EnergyMode.allCases.sorted {
            $0.displaySortIndex < $1.displaySortIndex
        }
        .map { item in
            item.systemColor
        }
    }
    
    private var spacing: CGFloat {
        items == 3 ? 3.5 : 5 // 3.5 was 4 before
    }
    private let labelSpacing: CGFloat = 6
    
    var body: some View {
        //0 hold color          (hold)      1
        
        //1 animate out         (ease)      1
        //1 animate in          (ease)      2
        
        //2 hold color          (hold)      2
        
        //3 animate out         (ease)      2
        //3 animate in          (ease)      3
        
        //4 hold                (hold)      3
        
        //5 animate out         (ease)      3
        
        //6 hold                (reset)     -
        
        //7 animate in (repeat) (ease)      1
        
        SettingsPicker(padding: .leading) {
            SettingsPickerOption {
                .init {
                    useStaticHighlightColor
                } set: { _ in
                    useStaticHighlightColor = true
                }
            } content: {
                HStack {
                    VStack(alignment: .leading, spacing: spacing) {
                        ForEach(0..<items, id: \.self) { index in
                            LayoutPreviewRow(item: index, numItems: items)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
            } label: {
                Text("System")
            }
            
            SettingsPickerOption {
                .init {
                    !useStaticHighlightColor
                } set: { _ in
                    useStaticHighlightColor = false
                }
            } content: {
                HStack {
                    VStack(alignment: .leading, spacing: spacing) {
                        ForEach(0..<items, id: \.self) { index in
                            LayoutPreviewRow(item: index, numItems: items, highlight: colors[index])
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
            } label: {
                Text("App")
            }
        }
    }
}

#Preview {
    var colors = ["Red", "Green", "Blue", "Tartan"]
    var selectedColor = "Red"
    
    return VStack {
        SettingsThemePicker()
            .padding(50)
            .environment(AppState.preview)
        
//        Picker("Picker", selection: .init(get: {selectedColor}, set: { _ in })) {
//            ForEach(colors, id: \.self) {
//                Text($0)
//            }
//        }
    }
}


struct ThemePicker<SelectionValue, Content: View, Label: View>: View {
    @Binding var selection: SelectionValue
    var content: Content
    var label: Label
    
    init(selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        self._selection = selection
        self.content = content()
        self.label = label()
    }
    
    var body: some View {
        _VariadicView.Tree( Helper(_body: {children in
            ForEach(children) { child in
                Color.clear
//                var tag = child[SomeWerid]
            }
        }), content: { self })
    }
}

fileprivate struct Helper<Result: View>: _VariadicView_MultiViewRoot {
    @ViewBuilder var _body: (_VariadicView.Children) -> Result
    
    func body(children: _VariadicView.Children) -> some View {
//        Color.clear
//        _body(children)
    }
}

//struct ThemePickerLayout<Result: View>: View {
//    var body: some View {
//        _VariadicView.Tree( Helper(_body: {children in Color.clear}), content: { self })
//    }
//}
