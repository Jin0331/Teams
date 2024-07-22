//
//  ProfileView.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    
    @State var store : StoreOf<ProfileFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Text("hi profile")
        }
    }
    
}
