//
//  AnotherView.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 18.08.2024.
//

import SwiftUI

struct AnotherView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("This is bottom sheet")
            Image(systemName: "doc.text.image")
                .resizable()
                .scaledToFit()
                .size(100)
            Spacer()
        }
    }
}

#Preview {
    AnotherView()
}
