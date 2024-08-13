//
//  BottomSheetModifier.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 13.08.2024.
//

import SwiftUI

struct BottomSheet<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var isShowingDragIndicator: Bool = true
    var detents: Set<BottomSheetDetent>?
    let content: () -> PopupContent

    @State private var viewState: BottomSheetDetent = .bySize
    @State private var contentOffset: CGFloat = .zero
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                sheetBackground
            }
        }
        .overlay(
            Group {
                if isPresented {
                    sheet
                }
            }
        )
        .onAppear {
            setViewState()
        }
    }
}

private extension BottomSheet {
    func setViewState() {
        guard let detents = detents, !detents.isEmpty else {
            return
        }

        if detents.count == 1, let singleDetent = detents.first {
            viewState = singleDetent
        } else {
            if let minimumDetent = detents.sorted(by: { $0.rawValue < $1.rawValue }).first {
                viewState = minimumDetent
            }
        }
    }

    func dismiss() {
        withAnimation {
            isPresented = false
            contentOffset = .zero
        }
    }

    var contentBackgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var sheetBackgroundColor: Color {
        colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.3)
    }

    var sheetIndicator: some View {
        Capsule()
            .fill(.gray.opacity(0.5))
            .frame(width: 36, height: 4)
            .padding(.top, 4)
    }

    var sheet: some View {
        VStack {
            Spacer()
            VStack {
                ZStack(alignment: .top) {
                    content()
                    if isShowingDragIndicator {
                        sheetIndicator
                    }
                }

                if viewState != .bySize {
                    Spacer()
                }
            }
            .iflet(viewState.viewHeight) { view, viewHeight in
                view.frame(height: viewHeight)
            }
            .frame(maxWidth: .infinity)
            .background(contentBackgroundColor)
            .cornerRadius(16)
            .offset(y: contentOffset)

        }
        .transition(.move(edge: .bottom))
        .ignoresSafeArea(edges: .bottom)
        .gesture(dragGesture)
    }

    var sheetBackground: some View {
        sheetBackgroundColor
            .ignoresSafeArea()
            .onTapGesture {
                dismiss()
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged{ value in
                guard value.translation.height > .zero else { return }
                contentOffset = value.translation.height
            }
            .onEnded { value in
                print("log", #function, value.translation.height)
                withAnimation {
                    switch value.translation.height {
                    case  ...0:
                        guard viewState != .large else { return }
                        viewState.next()
                    case 0...100:
                        contentOffset = .zero
                    case 100...:
                        guard viewState == .large else {
                            print("log", #function, viewState)
                            dismiss()
                            return
                        }

                        guard detents?.contains(.medium) == true else {
                            dismiss()
                            print("log", #function, viewState)
                            return
                        }

                        contentOffset = .zero
                        viewState.previous()
                    default:
                        break
                    }
                }
            }
    }
}

extension View {
    func bottomSheet<Content>(
        isPresented: Binding<Bool>,
        detents: Set<BottomSheetDetent>? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            BottomSheet(
                isPresented: isPresented,
                detents: detents,
                content: content
            )
        )
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
}

enum BottomSheetDetent: Int, Equatable, CaseIterable {
    case bySize
    case medium
    case large

    mutating func next() {
        let allCases: [BottomSheetDetent] = Self.allCases
        self = allCases[(self.rawValue + 1) % allCases.count]
    }

    mutating func previous() {
        let allCases: [BottomSheetDetent] = Self.allCases
        self = allCases[(self.rawValue - 1) % allCases.count]
    }

    var viewHeight: CGFloat? {
        let screenSizeHeight: CGFloat = UIScreen.main.bounds.size.height
        let topInset: CGFloat  = (UIApplication
                .shared
                .connectedScenes
            .flatMap {
                ($0 as? UIWindowScene)?.windows ?? []
            }
            .first { $0.isKeyWindow }?.safeAreaInsets ?? .zero).top

        return switch self {
        case .bySize:
               nil
        case .medium:
            screenSizeHeight / 2
        case .large:
            screenSizeHeight - topInset
        }
    }
}

#Preview {
    ContentView()
}
