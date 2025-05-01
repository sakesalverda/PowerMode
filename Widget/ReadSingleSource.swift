//
//  ReadSingleSource.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 08/12/2023.
//

import WidgetKit
import SwiftUI

struct SingleModeWidgetView : View {
    var entry: SingleSourceProvider.Entry

    var body: some View {
        VStack {
            WidgetHeaderLarge(
                source: entry.displayPowerSource,
                activeSource: entry.shouldDisplayCurrentPowerSource ? entry.activePowerSource : nil,
                selectedMode: entry.selectedEnergyMode
            )
            
            Spacer()
            
            WidgetModeDisplay(selectedMode: entry.selectedEnergyMode)
//                .equatable()
        }
    }
}

struct ReadSingleSourceWidget: Widget {
    let kind: String = "nl.sakesalverda.PowerMode.ReadSingleEnergyMode"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SingleSourceProvider.Configuration.self, provider: SingleSourceProvider()) { entry in
            SingleModeWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
                .managedWidget(entry: entry)
        }
        .configurationDisplayName("Display Energy Mode")
        .description("Display the selected energy mode")
        .supportedFamilies([.systemSmall])
    }
}
