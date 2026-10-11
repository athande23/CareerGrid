//
//  CareerGridWidgetLiveActivity.swift
//  CareerGridWidget
//
//  Created by Aaditya Thande on 11/10/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CareerGridWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CareerGridWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CareerGridWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CareerGridWidgetAttributes {
    fileprivate static var preview: CareerGridWidgetAttributes {
        CareerGridWidgetAttributes(name: "World")
    }
}

extension CareerGridWidgetAttributes.ContentState {
    fileprivate static var smiley: CareerGridWidgetAttributes.ContentState {
        CareerGridWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CareerGridWidgetAttributes.ContentState {
         CareerGridWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CareerGridWidgetAttributes.preview) {
   CareerGridWidgetLiveActivity()
} contentStates: {
    CareerGridWidgetAttributes.ContentState.smiley
    CareerGridWidgetAttributes.ContentState.starEyes
}
