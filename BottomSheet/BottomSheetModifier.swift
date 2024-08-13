//
//  BottomSheetModifier.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 13.08.2024.
//

import SwiftUI

struct BottomSheet<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let content: () -> PopupContent
    private let screenSize: CGSize = UIScreen.main.bounds.size
    @State private var presenterContentRect: CGRect = .zero
    @State private var sheetContentRect: CGRect = .zero
    @State private var currentOffset: CGFloat = .zero

    func body(content: Content) -> some View {
        ZStack {
            content
                .frameGetter($presenterContentRect)

            if isPresented {
                popupBackground()
            }
        }
        .overlay(
            Group {
                if isPresented {
                    sheet()
                }
            }
        )
        .onAppear {
            withAnimation {

            }
        }
    }

    func dismiss() {
        isPresented = false
    }

    private func sheet() -> some View {
        VStack {
            Spacer()
            content()
                .frameGetter($sheetContentRect)
                .frame(width: screenSize.width)
                .offset(x: 0, y: currentOffset)
                .animation(.linear, value: currentOffset)
                .ignoresSafeArea()
        }
    }

    private func popupBackground() -> some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .animation(.linear, value: isPresented)
            .onTapGesture {
                withAnimation {
                    dismiss()
                }
            }
    }
}

extension View {
    func popup<Content>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            BottomSheet(isPresented: isPresented, content: content)
        )
    }

    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }
}


struct FrameGetter: ViewModifier {
    @Binding var frame: CGRect

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy -> AnyView in
                let rect = proxy.frame(in: .global)

                // This avoids an infinite layout loop
                if rect.integral != self.frame.integral {
                    DispatchQueue.main.async {
                        self.frame = rect
                    }
                }

                return AnyView(EmptyView())
            }
            .ignoresSafeArea()
        )
    }
}
