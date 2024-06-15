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
    struct State : Equatable{
        let id = UUID()
        @Presents var login: AuthFeature.State?
    }
    
    enum Action {
        case loginButtonTapped
    }
}
