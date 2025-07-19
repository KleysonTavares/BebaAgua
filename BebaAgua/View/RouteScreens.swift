//
//  RouteScreens.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 04/04/25.
//

import SwiftUI

enum RouteScreensEnum: Hashable {
    case welcome
    case gender
    case weight
    case age
    case wakeUp
    case bedTime
}

struct RouteScreen {
    @ViewBuilder
    static func destination(for route: RouteScreensEnum, path: Binding<NavigationPath>) -> some View {
        switch route {
        case .welcome:
            WelcomeView()
        case .gender:
            GenderSelectionView(path: path)
        case .weight:
            WeightSelectionView(path: path)
        case .age:
            AgeSelectionView(path: path)
        case .wakeUp:
            WakeUpSelectionView(path: path)
        case .bedTime:
            BedTimeSelectionView(path: path)
        }
    }
}
