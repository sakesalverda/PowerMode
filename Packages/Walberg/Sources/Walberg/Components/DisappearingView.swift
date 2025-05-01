//
//  DisappearingView.swift
//
//
//  Created by Sake Salverda on 12/02/2024.
//

import SwiftUI

public struct DisappearingView<Content: View, V: Equatable>: View {
    var after: Duration
    
    var content: Content
    
    var trigger: Binding<V>?
    
    var animation: Animation?
    
    public init(after: Duration, trigger: Binding<V>? = nil, animation: Animation? = nil, @ViewBuilder content: () -> Content) {
        self.after = after
        self.trigger = trigger
        self.animation = animation
        self.content = content()
    }
    
    @State private var isVisible: Bool = false
    
    @State private var task: Task<(), Error>? = nil
    
    private func setupTask() {
        if let task {
            task.cancel()
        }
        
        task = Task {
            try await Task.sleep(for: after)
            
            withAnimation(animation) {
                isVisible = false
            }
        }
    }
    
    public var body: some View {
        Group {
            if isVisible {
                content
                    .task {
                        setupTask()
                    }
//                    .transition(.move(edge: .trailing))
                    .transition(.magic)
            }
        }
        .onChange(of: trigger?.wrappedValue) {
            withAnimation(animation) {
                isVisible = true
            }
            
            setupTask()
        }
    }
}

#Preview {
    StatePreviewWrapper(true) { state in
        VStack {
            HStack {
                Text("Normal text")
                
                DisappearingView(after: Duration.milliseconds(1000), trigger: state, animation: .default) {
                    Text("Inserted text")
                }
            }
            
            Button {
                withAnimation {
                    state.wrappedValue.toggle()
                }
            } label: {
                Text("Test")
            }
        }
    }
    .frame(width: 400)
}
