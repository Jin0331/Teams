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
            case let .profileOther(store):
                ProfileOtherView(store: store)
            }
        }
    }
}


@Reducer
struct ProfileCoordinator {
    @ObservableState
    struct State : Equatable {
        static func initialState(mode : ProfileRootMode = .me, tabViewMode : Bool = false, userID : String? = nil) -> Self {
            
            switch mode {
            case .me:
                return Self(routes: [.root(.profile(.init(tabViewMode: tabViewMode)), embedInNavigationView: tabViewMode)])
            case .other:
                return Self(routes: [.root(.profileOther(.init(userID: userID)), embedInNavigationView: false)])
            }
            
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
                
            case .router(.routeAction(_, action: .profileEdit(.editComplete))):
                state.routes.goBack()
                
                return .send(.router(.routeAction(id: .profile, action: .profile(.profileEditComplete))))
                
            default :
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

extension ProfileCoordinator {
    enum ProfileRootMode {
        case me
        case other
    }
}
