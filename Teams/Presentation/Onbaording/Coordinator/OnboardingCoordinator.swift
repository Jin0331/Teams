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
        static let initialState = State(
            routes: [.root(.onboarding(.init()), embedInNavigationView: true)]
        )
        var routes : [Route<OnboardingScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<OnboardingScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                
            case .router(.routeAction(_, action: .onboarding(.loginButtonTapped))):
                state.routes.presentSheet(.auth(.init()))
                
            case .router(.routeAction(_, action: .auth(.emailLoginButtonTapped))):
                state.routes.presentSheet(.emailLogin(.init()))
                
            case .router(.routeAction(_, action: .auth(.signUpButtonTapped))):
                state.routes.presentSheet(.signUp(.init()))
                                
            case .router(.routeAction(_, action: .signUp(.dismiss))), .router(.routeAction(_, action: .emailLogin(.dismiss))):
                state.routes.dismiss()
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
        
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
                    .presentationDetents([.height(290)])
                    .presentationDragIndicator(.visible)
            case let .signUp(store : store):
                SignUpView(store: store)
            case let .emailLogin(store):
                EmailLoginView(store: store)
            }
        }
    }
}
