//
//  WaterWidget.swift
//  WaterWidget
//
//  Created by Kleyson Tavares on 24/07/25.
//

import WidgetKit
import SwiftUI

@main
struct WaterWidget: Widget {
    let kind: String = "WaterWidget"
    let waterProgress = NSLocalizedString("waterProgress", bundle: .main, comment: "")
    let description = NSLocalizedString("description", bundle: .main, comment: "")

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterProvider()) { entry in
            WaterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(LocalizedStringKey(waterProgress))
        .description(LocalizedStringKey(description))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WaterWidget()
} timeline: {
    WaterEntry(date: .now)
}

#Preview(as: .systemMedium) {
    WaterWidget()
} timeline: {
    WaterEntry(date: .now)
}
