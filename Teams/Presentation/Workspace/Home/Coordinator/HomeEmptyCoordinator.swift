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
    case profile(ProfileCoordinator)
}

struct HomeEmptyCoordinatorView : View {
    let store : StoreOf<HomeEmptyCoordinator>
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .emptyView(store):
                HomeEmptyView(store: store)
            case let .workspaceAdd(store):
                WorkspaceAddView(store: store)
            case let .profile(store):
                ProfileCoordinatorView(store: store)
            }
        }
    }
    
}

@Reducer
struct HomeEmptyCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(routes: [.root(.emptyView(.init()), embedInNavigationView: true)])
        var routes : [Route<HomeEmptyScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<HomeEmptyScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                
            case .router(.routeAction(_, action: .emptyView(.buttonTapped(.createWorkspaceTapped)))):
                state.routes.presentSheet(.workspaceAdd(.init()))
            
            case .router(.routeAction(_, action: .workspaceAdd(.dismiss))):
                state.routes.dismiss()
                
            case .router(.routeAction(_, action: .emptyView(.buttonTapped(.profileOpenTapped)))):
                state.routes.push(.profile(.initialState()))
                
            case .router(.routeAction(_, action: .profile(.router(.routeAction(_, action: .profile(.goBack)))))):
                state.routes.goBack()
                
            default:
              break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
