//
//  CareerGridWidgetBundle.swift
//  CareerGridWidget
//
//  Created by Aaditya Thande on 11/10/2026.
//

import WidgetKit
import SwiftUI

@main
struct CareerGridWidgetBundle: WidgetBundle {
    var body: some Widget {
        CareerGridWidget()
        CareerGridWidgetControl()
        CareerGridWidgetLiveActivity()
    }
}
