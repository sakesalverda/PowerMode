//
//  AppIntent.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 08/12/2023.
//

import WidgetKit
import AppIntents

enum WidgetPowerSource: String, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: "Power Source")
    
    case current
    case battery
    case adapter
    
    static var caseDisplayRepresentations: [WidgetPowerSource : DisplayRepresentation] = [
        .current: "Active Power Source",
        .battery: "Battery",
        .adapter: "Adapter"
    ]
    
    var widgetLabel: String {
        switch self {
            case .current:
                "Current"
            case .battery:
                "Battery"
            case .adapter:
                "Adapter"
        }
    }
}

struct PowerSourceAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration for power source selection"
    static var description = IntentDescription("Add description here.")
    
    @Parameter(title: "Power Source", default: .current)
    var powerSource: WidgetPowerSource
}
