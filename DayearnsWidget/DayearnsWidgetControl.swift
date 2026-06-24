//
//  DayearnsWidgetControl.swift
//  DayearnsWidget
//
//  Created by Jubi on 5/26/25.
//

import AppIntents
import SwiftUI
import WidgetKit

struct DayearnsWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "Quang.DayEarns.DayearnsWidgetControl",
            provider: Provider()
        ) { _ in
            ControlWidgetButton(action: OpenDayEarnsIntent()) {
                Label("DayEarns", systemImage: "scroll")
            }
        }
        .displayName("DayEarns")
        .description("Open DayEarns quickly.")
    }
}

extension DayearnsWidgetControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool { false }
        func currentValue() async throws -> Bool { false }
    }
}

struct OpenDayEarnsIntent: AppIntent {
    static let title: LocalizedStringResource = "Open DayEarns"
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}