//
//  OnboardingCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/14/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

@Reducer(state: .equatable)
enum OnboardingScreen {
    case onboarding(OnboardingFeature)
    case auth(AuthFeature)
    case signUp(SignUpFeature)
    case emailLogin(EmailLoginFeature)
}

@Reducer
struct OnboardingCoordinator {
    @ObservableState
    struct State : Equatable {
        var routes : [Route<OnboardingScreen.State>]
    }
    
    enum Action {
      case router(IndexedRouterActionOf<OnboardingScreen>)
    }
}

struct OnboardingCoordinatorView : View {
    let store : StoreOf<OnboardingCoordinator>
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .onboarding(store):
                OnboardingView(store: store)
            case let .auth(store):
                AuthView(store: store)
            case let .signUp(store : store):
                SignUpView(store: store)
            case let .emailLogin(store):
                EmailLoginView(store: store)
            }
        }
    }
}

