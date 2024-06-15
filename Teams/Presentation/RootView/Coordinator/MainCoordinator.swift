//
//  MainCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/15/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct MainCoordinatorView : View {
    @State var store : StoreOf<MainCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.isLogined {
                    SplashView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    OnboardingCoordinatorView(store: store.scope(state: \.onboarding, action: \.onboarding))
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
        }
    }
}

@Reducer
struct MainCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(onboarding: .initialState, isLogined: false)
        var onboarding : OnboardingCoordinator.State
        var isLogined : Bool
    }
    
    enum Action {
        case onboarding(OnboardingCoordinator.Action)
    }
    
    var body : some ReducerOf<Self> {
        
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingCoordinator()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onboarding(.router(.routeAction(_, action: .emailLogin(.loginComplete)))):
                state.isLogined = true
            case .onboarding(.router(.routeAction(_, action: .signUp(.signUpComplete)))):
                state.isLogined = true
            case .onboarding(.router(.routeAction(_, action: .auth(.loginComplete)))):
                state.isLogined = true
            default:
              break
            }
            return .none
        }
    }
}
