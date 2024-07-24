//
//  ChannelCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct ChannelCoordinatorView : View {
    let store : StoreOf<ChannelCoordinator>
    
    var body : some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .add(store):
                ChannelAddView(store: store)
            case let .search(store):
                ChannelSearchView(store: store)
            case let .chat(store):
                ChannelChatView(store: store)
            case let .setting(store):
                ChannelSettingView(store: store)
            case let .owner(store):
                ChannelOwnerChangeView(store: store)
            }
        }
    }
    
}

@Reducer
struct ChannelCoordinator {
    @ObservableState
    struct State : Equatable {
        static func initialState(mode : ChannelRootMode = .search, workspaceCurrent: Workspace? = nil) -> Self {
            
            switch mode {
            case .add :
                return Self(
                    routes: [.root(.add(.init()), embedInNavigationView: false)]
                )

            case .search:
                return Self(
                    routes: [.root(.search(.init()), embedInNavigationView: true)]
                )
            }
        }
                
        var routes: IdentifiedArrayOf<Route<ChannelScreen.State>>
        var currentWorkspace : Workspace?
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<ChannelScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            
            default :
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

extension ChannelCoordinator {
    enum ChannelRootMode {
        case add
        case search
    }
}
