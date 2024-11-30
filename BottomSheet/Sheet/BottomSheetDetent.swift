//
//  BottomSheetDetent.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 15.08.2024.
//

import SwiftUI

enum BottomSheetDetent: Equatable, CaseIterable, Hashable {
    static var allCases: [BottomSheetDetent] = [
        .bySize,
        .large,
        .medium,
        .height(.zero),
        .fullScreen
    ]

    case bySize
    case medium
    case large
    case height(_ value: CGFloat)
    case fullScreen

    static func == (lhs: BottomSheetDetent, rhs: BottomSheetDetent) -> Bool {
        switch (lhs, rhs) {
        case (.bySize, .bySize), (.medium, .medium), (.large, .large), (.fullScreen, .fullScreen):
            return true
        case (.height(let lhsHeight), .height(let rhsHeight)):
            return lhsHeight == rhsHeight
        default:
            return false
        }
    }

    mutating func next(_ currentIndex: Int, _ availableDetents: [Self]) {
        let nextIndex: Int = (currentIndex + 1) % availableDetents.count
        self = availableDetents[nextIndex]
    }

    mutating func previous(_ currentIndex: Int, _ availableDetents: [Self]) {
        let previousIndex: Int = (currentIndex - 1) % availableDetents.count
        self = availableDetents[previousIndex]
    }

    var viewHeight: CGFloat {
        let screenSizeHeight: CGFloat = UIScreen.main.bounds.size.height
        let topInset: CGFloat = (
            UIApplication
                .shared
                .connectedScenes
                .flatMap {
                    ($0 as? UIWindowScene)?.windows ?? []
                }
                .first { $0.isKeyWindow }?.safeAreaInsets ?? .zero
        ).top

        return switch self {
        case .medium:
            screenSizeHeight / 2
        case .large:
            screenSizeHeight - topInset
        case .height(let height):
            height
        case .fullScreen:
            screenSizeHeight + topInset
        case .bySize:
                .zero
        }
    }
}
