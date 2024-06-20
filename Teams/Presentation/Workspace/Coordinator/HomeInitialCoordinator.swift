//
//  HomeInitialCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/19/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

@Reducer(state: .equatable)
enum HomeInitialScreen {
    case initial(HomeInitialFeature)
    case workspaceAdd(WorkspaceAddFeature)
}

struct HomeInitialCoordinatorView : View {
    let store : StoreOf<HomeInitialCoordinator>
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .initial(store):
                HomeInitialView(store: store)
            case let .workspaceAdd(store):
                WorkspaceAddView(store: store)
            }
        }
    }
}

@Reducer
struct HomeInitialCoordinator {
    @ObservableState
    struct State : Equatable {
        static func initialState(nickname : String = "") -> Self {
            Self(routes: [.root(.initial(.init(nickname: nickname)))])
        }
        var routes : [Route<HomeInitialScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<HomeInitialScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                
            case .router(.routeAction(_, action: .initial(.createWorkspaceTapped))):
                state.routes.presentSheet(.workspaceAdd(.init()))
            
            case .router(.routeAction(_, action: .workspaceAdd(.dismiss))):
                state.routes.dismiss()
                
            default:
              break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
