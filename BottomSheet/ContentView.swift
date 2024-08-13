//
//  ContentView.swift
//  BottomSheet
//
//  Created by Kamil Suleymanov on 13.08.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingSheet = false

    var body: some View {
        VStack {
            Button {
                withAnimation {
                    isShowingSheet = true
                }
            } label: {
                Text("show sheet")
            }
        }
        .padding()
        .bottomSheet(isPresented: $isShowingSheet) {
            ScrollView {
                VStack {
                    ForEach(0..<100) {
                        Text("\($0)")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
//        .sheet(isPresented: $isShowingSheet) {
//            ScrollView {
//                VStack {
//                    ForEach(0..<100) {
//                        if #available(iOS 16.0, *) {
//                            Text("\($0)")
//                                .frame(maxWidth: .infinity)
//                                .presentationDetents([.medium, .large])
//                        } else {
//                            // Fallback on earlier versions
//                        }
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity)
//            .padding()
//        }
    }
}

#Preview {
    ContentView()
}
