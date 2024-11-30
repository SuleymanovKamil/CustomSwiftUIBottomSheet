//
//  Extensions.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 14.08.2024.
//

import SwiftUI

extension View {
    /// Applies the `BottomSheet` modifier to create a customisable bottom sheet.
    ///
    /// - Parameters:
    ///   - cornerRadius: The corner radius of the bottom sheet. The default value is 20, and the maximum value is 30.
    ///   - isShowingBackground: A boolean value indicating whether the background behind the bottom sheet should be displayed. The default value is `true`.
    ///   - isShowingShadow: A boolean value indicating whether the shadow above the bottom sheet should be displayed. The default value is `false`.
    ///   - detents: An array of `BottomSheetDetent` objects that define the allowable sizes of the bottom sheet. If `nil`, the size is determined by the content. The array may include `.medium`, `.large`, and/or `.custom(height)`. The custom height cannot be greater than large.
    ///   - content: The view that will be displayed inside the bottom sheet. It is not recommended to use ScrollView, List, or other views with vertical scrolling, as scroll gestures and the dragGesture of the bottom sheet may conflict with each other.

    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        cornerRadius: CGFloat = 20,
        isShowingBackground: Bool = true,
        isShowingShadow: Bool = false,
        presentationDetents: [BottomSheetDetent]? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            BottomSheet(
                isPresented: isPresented,
                cornerRadius: cornerRadius,
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

    func UIKitView<T: UIView>(as type: T.Type, _ completion: @escaping ((T) -> Void)) -> some View {
        self.background(
            UIKitViewExtractor { view in
                if let someView = view as? T {
                    completion(someView)
                }
            }
        )
        .compositingGroup()
    }

    func contentSize(onChange: @escaping (CGSize) -> Void) -> some View {
        self.modifier(ContentSize(action: onChange))
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

private struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct ContentSize: ViewModifier {
    let action: (CGSize) -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self, perform: action)
    }
}

private struct UIKitViewExtractor: UIViewRepresentable {
    let onViewExtracted: (UIView) -> Void

    func makeUIView(context: Context) -> UIView {
        let view: UIView = .init(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        DispatchQueue.main.async {
            if let UIKitView = view.superview?.superview?.subviews.last?.subviews.first {
                onViewExtracted(UIKitView)
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
