//
//  BottomSheetDetent.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 15.08.2024.
//

import SwiftUI

enum BottomSheetDetent: Equatable, CaseIterable {
    static var allCases: [BottomSheetDetent] = [
        .large,
        .medium,
        .custom(.zero)
    ]

    case medium
    case large
    case custom(_ height: CGFloat)

    static func == (lhs: BottomSheetDetent, rhs: BottomSheetDetent) -> Bool {
        switch (lhs, rhs) {
        case (.medium, .medium), (.large, .large):
            return true
        case (.custom(let lhsHeight), .custom(let rhsHeight)):
            return lhsHeight == rhsHeight
        default:
            return false
        }
    }

    mutating func next(_ availableDetents: [Self]) {
        guard let currentIndex = availableDetents.firstIndex(of: self),
              currentIndex < availableDetents.count - 1 else {
            return
        }

        let nextIndex: Int = (currentIndex + 1) % availableDetents.count
        self = availableDetents[nextIndex]
    }

    mutating func previous(_ availableDetents: [Self]) {
        guard let currentIndex = availableDetents.firstIndex(of: self),
              currentIndex > 0 else {
            return
        }

        let previousIndex: Int = (currentIndex - 1) % availableDetents.count
        self = availableDetents[previousIndex]
    }

    var viewHeight: CGFloat? {
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
        case .custom(let height):
            height
        }
    }
}
