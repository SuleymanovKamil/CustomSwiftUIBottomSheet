//
//  Environments.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 29.08.2024.
//

import SwiftUI

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?.safeAreaInsets ?? .zero).insets
    }
}

private struct ShowingDragIndicator: EnvironmentKey {
    static var defaultValue: Bool = false
}

private struct ShowingCloseButton: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }

    var showingDragIndicator: Bool {
        get { self[ShowingDragIndicator.self] }
        set { self[ShowingDragIndicator.self] = newValue }
    }

    var showingCloseButton: Bool {
        get { self[ShowingCloseButton.self] }
        set { self[ShowingCloseButton.self] = newValue }
    }
}

private extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension View {
    func showingDragIndicator(_ showingDragIndicator: Bool = true) -> some View {
        environment(\.showingDragIndicator, showingDragIndicator)
    }

    func showingCloseButton(_ showingCloseButton: Bool = true) -> some View {
        environment(\.showingCloseButton, showingCloseButton)
    }
}
