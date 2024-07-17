//
//  DMListView.swift
//  Teams
//
//  Created by JinwooLee on 7/17/24.
//

import SwiftUI
import ComposableArchitecture

struct DMListView : View{
    
    @State var store : StoreOf<DMListFeature>
    
    var body : some View {
        
        WithPerceptionTracking {
            VStack {
                Text("HI")
            }
        }
    }
}
