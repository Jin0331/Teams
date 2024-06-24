//
//  HomeView.swift
//  Teams
//
//  Created by JinwooLee on 6/14/24.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {

    let store : StoreOf<HomeFeature>

    var body: some View {
        VStack {
            Text("hi")
      }
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeFeature.State(), reducer: {
        HomeFeature()
    }))
}
