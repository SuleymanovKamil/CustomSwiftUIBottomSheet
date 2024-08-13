//
//  ContentView.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 13.08.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingShortPaywall = false

    var body: some View {
        VStack {
            Button {
                withAnimation {

                    isShowingShortPaywall = true
                }
            } label: {
                Text("show sheet")
            }

        }
        .padding()
        .popup(isPresented: $isShowingShortPaywall) {
            VStack {
                Spacer()
                Text("This is sheet")
                    .font(.largeTitle)
                     Spacer()
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .background(.red)
        }
    }
}

#Preview {
    ContentView()
}
