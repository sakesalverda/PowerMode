//
//  DonationThanksView.swift
//  PowerMode
//
//  Created by Sake Salverda on 12/02/2024.
//

import SwiftUI

struct DonationThanksView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.pink)
                .imageScale(.large)
                .padding(14)
                .phaseAnimator([0, 0.15], content: { view, phase in
                    view.scaleEffect(1 + phase)
                }, animation: { phase in
                    let heartbeats: Double = 50
                    
                    return .linear(duration: 60 / heartbeats / 2)
                })
                .background(.quinary, in: Circle())
            
            Text("Thank you for supporting the app")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("We hope you enjoy using the app!")
        }
    }
}

#Preview {
    SettingsPreview {
        DonationThanksView()
            .donationViewFrame()
            .padding()
    }
}
