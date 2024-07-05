//
//  HomeView.swift
//  Teams
//
//  Created by JinwooLee on 6/14/24.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    
    @State var store : StoreOf<HomeFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            VStack {
                Text("hi")
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 100 {
                            store.send(.openSideMenu)
                        } else if value.translation.width < -100 {
                            store.send(.closeSideMenu)
                        }
                    }
            )
            .onAppear {
                print(store.workspaceCurrent, "히히")
            }
        }
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeFeature.State(workspaceCurrent: nil), reducer: {
        HomeFeature()
    }))
}
