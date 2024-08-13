//
//  Extensions.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 14.08.2024.
//

import SwiftUI

extension View {
    func bottomSheet<Content>(
        isPresented: Binding<Bool>,
        detents: [BottomSheetDetent]? = nil,
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
