//
//  SideMenuCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/24/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

@Reducer(state: .equatable)
enum SideMenuScreen {
    case sidemenu(SideMenuFeature)
    case workspaceAdd(WorkspaceAddFeature)
}

struct SideMenuCoordinatorView : View {
    let store : StoreOf<SideMenuCoordinator>
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .sidemenu(store):
                SideMenuView(store: store)
            case let .workspaceAdd(store):
                WorkspaceAddView(store: store)
            }
        }
    }
}

@Reducer
struct SideMenuCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(routes: [.root(.sidemenu(.init()))])
        var routes : [Route<SideMenuScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<SideMenuScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                
            case .router(.routeAction(_, action: .sidemenu(.createWorkspaceTapped))):
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
