//
//  LinearGradient+Ext.swift
//  MaintenanceTrackerApp
//
//  Created by Mark Martin on 6/28/23.
//

import SwiftUI

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
