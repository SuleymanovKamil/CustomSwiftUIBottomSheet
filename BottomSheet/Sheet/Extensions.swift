//
//  Extensions.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 14.08.2024.
//

import SwiftUI

extension View {
    /// Applies the `BottomSheet` modifier to create a customizable bottom sheet.
    ///
    /// - Parameters:
    ///   - cornerRadius: The corner radius of the bottom sheet. The default value is 20, and the maximum value is 30.
    ///   - isShowingDragIndicator: A boolean value indicating whether the drag indicator should be displayed. The default value is `true`.
    ///   - isShowingCloseButton: A boolean value indicating whether the close button should be displayed. The default value is `false`.
    ///   - isShowingBackground: A boolean value indicating whether the background behind the bottom sheet should be displayed. The default value is `true`.
    ///   - isShowingShadow: A boolean value indicating whether the shadow above the bottom sheet should be displayed. The default value is `false`.
    ///   - detents: An array of `BottomSheetDetent` objects that define the allowable sizes of the bottom sheet. If `nil`, the size is determined by the content. The array may include `.medium`, `.large`, and/or `.custom(height)`. The custom height cannot be greater than large.
    ///   - content: The view that will be displayed inside the bottom sheet. It is not recommended to use ScrollView, List, or other views with vertical scrolling, as scroll gestures and the dragGesture of the bottom sheet may conflict with each other.

    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        cornerRadius: CGFloat = 20,
        isShowingDragIndicator: Bool = true,
        isShowingCloseButton: Bool = false,
        isShowingBackground: Bool = true,
        isShowingShadow: Bool = false,
        presentationDetents: [BottomSheetDetent]? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            BottomSheet(
                isPresented: isPresented,
                cornerRadius: cornerRadius,
                isShowingDragIndicator: isShowingDragIndicator,
                isShowingCloseButton: isShowingCloseButton,
                isShowingBackground: isShowingBackground, 
                isShowingShadow: isShowingShadow,
                detents: presentationDetents,
                content: content
            )
        )
    }
    
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        @ViewBuilder transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func iflet<Content: View, T>(
        _ conditional: T?,
        @ViewBuilder _ content: (Self, _ value: T) -> Content
    ) -> some View {
        if let value = conditional {
            content(self, value)
        } else {
            self
        }
    }

    func size(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }
}

extension UIDevice {
    static var hasSafeArea: Bool {
        if let safeAreaInsets = (UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?.safeAreaInsets ?? .zero) {
            return safeAreaInsets.bottom != .zero
        }
        return false
    }
}

extension Array where Element == BottomSheetDetent {
    var setDetents: [BottomSheetDetent] {
        let maxHeight = BottomSheetDetent.fullScreen.viewHeight
        return self
            .filter { $0.viewHeight <= maxHeight }
            .sorted { $0.viewHeight < $1.viewHeight }
            .reduce(into: []) { result, element in
                if !result.contains(element) {
                    result.append(element)
                }
            }
    }
}

struct CustomRoundedRectangle: Shape {
    let radius: CGFloat
    let corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path: UIBezierPath = .init(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        return Path(path.cgPath)
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?.safeAreaInsets ?? .zero).insets
    }
}

public extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
