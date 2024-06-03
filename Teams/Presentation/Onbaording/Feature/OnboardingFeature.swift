//
//  OnboardingFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/3/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct OnboardingFeature {
    
    @ObservableState
    struct State {
        @Presents var loginList: LoginFeature.State?
    }
    
    enum Action {
        case loginButtonTapped(PresentationAction<LoginFeature.Action>)
    }
    
//    var body : some ReducerOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case .loginButtonTapped:
//                
//            }
//        }
//    }
}
