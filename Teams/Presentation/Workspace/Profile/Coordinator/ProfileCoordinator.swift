//
//  ProfileCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct ProfileCoordinatorView : View {
    let store : StoreOf<ProfileCoordinator>
    
    var body : some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .profile(store):
                ProfileView(store: store)
            case let .profileEdit(store):
                ProfileEditView(store: store)
            }
        }
    }
}


@Reducer
struct ProfileCoordinator {
    @ObservableState
    struct State : Equatable {
        static func initialState() -> Self {
            Self(
                routes: [.root(.profile(.init()))]
            )
        }
        var routes: IdentifiedArrayOf<Route<ProfileScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<ProfileScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            
            case let .router(.routeAction(_, action: .profile(.viewTransition(.nicknameEdit(profile))))):
                state.routes.push(.profileEdit(.init(currentProfile: profile, viewType: .nickname)))
                
            case let .router(.routeAction(_, action: .profile(.viewTransition(.phonenumberEdit(profile))))):
                state.routes.push(.profileEdit(.init(currentProfile: profile, viewType: .phonenumber)))
                
            case .router(.routeAction(_, action: .profileEdit(.goBack))):
                state.routes.goBack()
                
            default :
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

