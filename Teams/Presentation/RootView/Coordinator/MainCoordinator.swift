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
                    if store.isSignUp { // 회원가입시
                        HomeInitialCoordinatorView(store: store.scope(state: \.homeInitial, action: \.homeInitial))
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else {
                        WorkspaceCoordinatorView(store: store.scope(state: \.workspace, action: \.workspace))
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                } else {
                    OnboardingCoordinatorView(store: store.scope(state: \.onboarding, action: \.onboarding))
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetLogin)) { notification in
            store.send(.refreshTokenExposed)
        }
    }
}

@Reducer
struct MainCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(onboarding: .initialState, homeInitial: .initialState(), workspace: .initialState, isLogined: false, isSignUp: false)
        var onboarding : OnboardingCoordinator.State
        var homeInitial : HomeInitialCoordinator.State
        var workspace : WorkspaceCoordinator.State
        var isLogined : Bool
        var isSignUp : Bool
    }
    
    enum Action {
        case onboarding(OnboardingCoordinator.Action)
        case homeInitial(HomeInitialCoordinator.Action)
        case workspace(WorkspaceCoordinator.Action)
        case refreshTokenExposed
    }
    
    var body : some ReducerOf<Self> {
        
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingCoordinator()
        }
        Scope(state: \.homeInitial, action: \.homeInitial) {
            HomeInitialCoordinator()
        }
        Scope(state: \.workspace, action: \.workspace) {
            WorkspaceCoordinator()
        }
        
        
        Reduce<State, Action> { state, action in
            switch action {
            case let .onboarding(.router(.routeAction(_, action: .emailLogin(.loginComplete(nickname))))):
                state.isLogined = true
                state.isSignUp = false
            case let .onboarding(.router(.routeAction(_, action: .signUp(.signUpComplete(nickname))))):
                state.isLogined = true
                state.isSignUp = true
                state.homeInitial = .initialState(nickname: nickname)
            case .onboarding(.router(.routeAction(_, action: .auth(.loginComplete)))):
                state.isLogined = true
                state.isSignUp = false
            case .homeInitial(.router(.routeAction(_, action: .initial(.dismiss)))):
                state.isLogined = true
                state.isSignUp = false
            case .refreshTokenExposed:
                state.isLogined = false
                state.isSignUp = false
            default:
              break
            }
            return .none
        }
    }
}
