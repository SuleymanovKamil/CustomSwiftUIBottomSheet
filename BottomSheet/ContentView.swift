//
//  ContentView.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 13.08.2024.
//

import SwiftUI

struct ContentView: View {
    var isUsingNativeSheet: Bool = false
    @State private var isShowingSheet = false

    var body: some View {
        VStack {
            Button {
                isShowingSheet.toggle()
            } label: {
                Text("Show bottom sheet")
                    .font(.system(size: 18, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue)
        .edgesIgnoringSafeArea(.all)
        .bottomSheet(
            isPresented: $isShowingSheet,
            presentationDetents: [.medium]
        ) {
            AnotherView()
        }
        .showingDragIndicator()
        .showingCloseButton()
    }
}

#Preview("Custom sheet") {
    ContentView()
}
