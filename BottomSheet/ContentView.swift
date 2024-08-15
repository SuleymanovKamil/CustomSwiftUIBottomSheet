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
        .ignoresSafeArea()
        .if(isUsingNativeSheet) { view in
            if #available(iOS 16.0, *) {
                view
                    .sheet(isPresented: $isShowingSheet) {
                        AnotherView()
                            .presentationDetents([.height(250), .medium, .large])
                    }
            }
        }
        .if(!isUsingNativeSheet) { view in
            view
                .bottomSheet(
                    isPresented: $isShowingSheet,
                    presentationDetents: [.height(250), .medium, .large, .fullScreen]
                ) {
                    AnotherView()
                }
        }
    }
}

#Preview("Custom sheet") {
    ContentView()
}

#Preview("Native sheet") {
    ContentView(isUsingNativeSheet: true)
}
