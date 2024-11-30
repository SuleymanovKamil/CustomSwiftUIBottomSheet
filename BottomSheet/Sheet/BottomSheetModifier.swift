//
//  BottomSheetModifier.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 13.08.2024.
//

import SwiftUI

struct BottomSheet<SheetContent: View>: ViewModifier {
    @Binding private var isPresented: Bool
    private let cornerRadius: CGFloat
    private let isShowingBackground: Bool
    private let isShowingShadow: Bool
    private let detents: [BottomSheetDetent]?
    private let content: () -> SheetContent
    private let delegate: ScrollViewDelegate = .init()

    @State private var isScrollEnabled: Bool = true
    @State private var viewState: BottomSheetDetent?
    @State private var contentOffset: CGFloat = .zero {
        willSet {
            guard newValue < .zero else { return }
            contentOffset = .zero
        }
    }
    @State private var contentHeight: CGFloat = .zero
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.safeAreaInsets) private var safeArea
    @Environment(\.showingDragIndicator) private var isShowingDragIndicator
    @Environment(\.showingCloseButton) private var isShowingCloseButton

    init(
        isPresented: Binding<Bool>,
        cornerRadius: CGFloat,
        isShowingBackground: Bool,
        isShowingShadow: Bool,
        detents: [BottomSheetDetent]?,
        @ViewBuilder content: @escaping () -> SheetContent
    ) {
        self._isPresented = isPresented
        self.cornerRadius = cornerRadius > 30 ? 20 : cornerRadius
        self.isShowingBackground = isShowingBackground
        self.isShowingShadow = isShowingShadow
        if let detents {
            self.detents = detents.setDetents
            viewState = self.detents?.first
        } else {
            self.detents = nil
        }
        self.content = content
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            sheetBackground
        }
        .overlay(sheet)
        .animation(.linear, value: isPresented)
    }
}

// MARK: - Methods

private extension BottomSheet {
    func dismiss() {
        isPresented = false
        contentOffset = .zero
        if let detents {
            viewState = detents.first
        }
    }
}

// MARK: - Views

private extension BottomSheet {
    @ViewBuilder
    var sheetBackground: some View {
        if isPresented {
            (isShowingBackground ? sheetBackgroundColor : .clear)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismiss()
                }
                .zIndex(1)
        }
    }

    @ViewBuilder
    var dragIndicator: some View {
        if isShowingDragIndicator  {
            ZStack(alignment: .top) {
                Capsule()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height: 16)
                    .padding(.top, 4)

                Capsule()
                    .fill(controlsColor)
                    .frame(width: 36, height: 4)
                    .padding(.top, 4)
            }
            .zIndex(Double(Int.max))
            .opacity(viewState == .fullScreen ? 0 : 1)
        }
    }

    @ViewBuilder
    var closeButton: some View {
        let isFullscreen = viewState == .fullScreen
        if isShowingCloseButton || isFullscreen {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .size(isFullscreen ? 30 : 20)
                    .foregroundColor(controlsColor)
                    .background(contentBackgroundColor)
                    .cornerRadius(isFullscreen ? 15 : 10)
                    .padding(10)
                    .if(isFullscreen) { image in
                        image
                            .padding(.top, safeArea.top)
                            .padding(.trailing, 4)
                            .offset(y: -contentOffset)
                    }
            }
        }
    }

    var sheetContent: some View {
        VStack(spacing: .zero) {
            if detents != nil {
                Spacer(minLength: .zero)
            }
            
            VStack {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .top) {
                        ScrollView {
                            content()
                                .contentSize { size in
                                    guard viewState == .bySize else {
                                        isScrollEnabled = size.height > (viewState?.viewHeight ?? .zero)
                                        return
                                    }

                                    guard size.height <= BottomSheetDetent.fullScreen.viewHeight else {
                                        viewState = .large
                                        return
                                    }

                                    isScrollEnabled = false
                                    contentHeight = size.height + safeArea.bottom
                                }
                                .padding(.top, 20)
                                .padding(.bottom, safeArea.bottom)
                        }
                        .UIKitView(as: UIScrollView.self) {
                            scrollLogic($0)
                        }

                        dragIndicator
                    }
                    .frame(maxWidth: .infinity)
                    
                    closeButton
                }

                if detents != nil {
                    Spacer(minLength: .zero)
                }
            }
        }
        .iflet(viewState?.viewHeight) { view, viewHeight in
            view.frame(height: viewHeight + contentHeight)
        }
        .frame(maxWidth: .infinity)
        .background(contentBackgroundColor)
        .clipShape(
            CustomRoundedRectangle(
                radius: cornerRadius,
                corners: viewState == .fullScreen &&
                !UIDevice.hasSafeArea ? [] : [.topRight, .topLeft]
            )
        )
        .offset(y: contentOffset)
        .animation(.linear, value: viewState)
        .animation(.linear, value: contentOffset)
    }

    @ViewBuilder
    var sheet: some View {
        if isPresented {
            VStack {
                Spacer(minLength: .zero)
                sheetContent
            }
            .if(isShowingShadow) {
                $0.shadow(color: shadowsColor, radius: 2, y: 1)
            }
            .transition(.move(edge: .bottom))
            .edgesIgnoringSafeArea(viewState == .fullScreen ? .all : .bottom)
            .gesture(dragGesture)
        }
    }
}

// MARK: - DragGesture Logic

private extension BottomSheet {
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0.05)
            .onChanged { value in
                onDraggingHandler(with: value.translation.height)
            }
            .onEnded { value in
                onEndedDragHandler(with: value.translation.height)
            }
    }

    func scrollLogic(_ view: UIView) {
        guard let scrollView = view as? UIScrollView else { return }

        scrollView.isScrollEnabled = isScrollEnabled
        delegate.onDrag = {
            onDraggingHandler(with: $0)
        }
        delegate.onDragEnded = {
            onEndedDragHandler(with: contentOffset)
        }
        scrollView.delegate = delegate
    }

    func nextDetent(for currentHeight: CGFloat) -> CGFloat? {
        guard let detents = detents else { return nil }
        return detents
            .compactMap { $0.viewHeight }
            .first { $0 > currentHeight }
    }

    func handleDragUp(with value: CGFloat) {
        guard value < -50 || value > 50,
              let viewState = viewState,
              let detents = detents,
              detents.count > 1,
              viewState != .large
        else { return }
        let currentHeight = viewState.viewHeight
        let nextDetentHeight = nextDetent(for: currentHeight) ?? value
        let largeDetentHeight = detents.last?.viewHeight ?? value
        let heightChange = abs(value) / 1.5
        let newHeight = max(currentHeight + heightChange, .zero)

        guard currentHeight < nextDetentHeight else { return }

        contentHeight = min(newHeight - currentHeight, min(nextDetentHeight, largeDetentHeight) - currentHeight)
    }

    func onDraggingHandler(with value: CGFloat) {
        guard value < 250 else {
            dismiss()
            return
        }
        guard value > .zero else {
            handleDragUp(with: value)
            return
        }

        contentOffset = value
    }

    func onEndedDragHandler(with value: CGFloat) {
        defer {
            if viewState != .bySize {
                contentHeight = .zero
            }
            contentOffset = .zero
        }

        switch value {
        case  ...(-100):
            toNextDetents()
        case -100...100:
            contentOffset = .zero
        default:
            toPreviousDetentOrDismiss()
        }
    }

    func toNextDetents() {
        guard let viewState,
              let detents,
              let currentIndex = detents.firstIndex(of: viewState),
              currentIndex < detents.count - 1
        else { return }
        self.viewState?.next(currentIndex, detents)
    }

    func toPreviousDetentOrDismiss() {
        guard let viewState,
              let detents,
              let currentIndex = detents.firstIndex(of: viewState),
              currentIndex > .zero
        else {
            dismiss()
            return
        }

        self.viewState?.previous(currentIndex, detents)
    }
}

// MARK: - Colors

private extension BottomSheet {
    var contentBackgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var shadowsColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var sheetBackgroundColor: Color {
        colorScheme == .dark ? .gray.opacity(0.5) : .black.opacity(0.3)
    }

    var controlsColor: Color {
        Color.gray.opacity(0.5)
    }
}

private final class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    var onDrag: ((CGFloat) -> Void)?
    var onDragEnded: (() -> Void)?
    private var isScrolling: Bool = false

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y < .zero else { return }

        isScrolling = true
        scrollView.bounces = false
        if let scrollViewGestures = scrollView.gestureRecognizers {
            for gesture in scrollViewGestures {
                if let panGesture = gesture as? UIPanGestureRecognizer {
                    guard panGesture.velocity(in: scrollView).y > .zero else { continue }
                    onDrag?(panGesture.translation(in: scrollView).y)
                }
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        onScrollDidEnd(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        onScrollDidEnd(scrollView)
    }

    private func onScrollDidEnd(_ scrollView: UIScrollView) {
        guard isScrolling else { return }
        onDragEnded?()
        isScrolling = false
        scrollView.bounces = true
    }
}

#Preview {
    ContentView()
}
