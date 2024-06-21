//
//  HomeEmptyViewCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/20/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

@Reducer(state : .equatable)
enum HomeEmptyScreen {
    case emptyView(HomeEmptyFeature)
    case workspaceAdd(WorkspaceAddFeature)
}

struct HomeEmptyViewCoordinatorView : View {
    let store : StoreOf<HomeEmptyViewCoordinator>
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .emptyView(store):
                HomeEmptyView(store: store)
            case let .workspaceAdd(store):
                WorkspaceAddView(store: store)
            }
        }
    }
    
}

@Reducer
struct HomeEmptyViewCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(routes: [.root(.emptyView(.init()))])
        var routes : [Route<HomeEmptyScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<HomeEmptyScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                
            case .router(.routeAction(_, action: .emptyView(.createWorkspaceTapped))):
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
