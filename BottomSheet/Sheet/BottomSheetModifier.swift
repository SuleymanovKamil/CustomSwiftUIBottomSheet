//
//  BottomSheetModifier.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 13.08.2024.
//

import SwiftUI

struct BottomSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool {
        didSet {
            setViewState()
        }
    }
    var isShowingDragIndicator: Bool = true
    var detents: [BottomSheetDetent]?
    let content: () -> SheetContent

    @State private var viewState: BottomSheetDetent?
    @State private var contentOffset: CGFloat = .zero
    @State private var dragGestureMinimumDistance: Double = 0.1
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
        guard let firstDetent = detents?.first else {
            return
        }

        viewState = firstDetent
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

                if detents != nil {
                    Spacer()
                }
            }
            .iflet(viewState?.viewHeight) { view, viewHeight in
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
        DragGesture(minimumDistance: dragGestureMinimumDistance)
            .onChanged { value in
                guard value.translation.height > .zero else { return }
                contentOffset = value.translation.height
            }
            .onEnded { value in
                withAnimation {
                    defer { contentOffset = .zero }
                    switch value.translation.height {
                    case  ...0:
                        guard let viewState, 
                              let detents,
                              let currentIndex = detents.firstIndex(of: viewState),
                              currentIndex < detents.count - 1 
                        else {
                            return
                        }

                        self.viewState?.next(detents)
                    case 0...100:
                        contentOffset = .zero
                    case 100...:
                        guard let viewState, 
                              let detents,
                              let currentIndex = detents.firstIndex(of: viewState),
                              currentIndex > .zero
                        else {
                            dismiss()
                            return
                        }

                        self.viewState?.previous(detents)
                    default:
                        break
                    }
                }
            }
    }
}

#Preview {
    ContentView()
}
