//
//  AnotherView.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 18.08.2024.
//

import SwiftUI

struct AnotherView: View {
    var body: some View {
        VStack {
            Color.gray
                .frame(height: 200)

            ScrollView {
                VStack {
                    ForEach(0..<100) {
                        Text("\($0)")
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            Color.red
                .frame(height: 200)
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
