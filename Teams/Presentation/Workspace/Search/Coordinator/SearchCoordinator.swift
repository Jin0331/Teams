//
//  SearchCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct SearchCoordinatorView : View {
    let store : StoreOf<SearchCoordinator>
    
    var body : some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .search(store):
                SearchView(store: store)
            case let .channel(store):
                ChannelCoordinatorView(store: store)
            case let .dmChat(store):
                DMChatView(store: store)
            case let .profile(store):
                ProfileCoordinatorView(store: store)
            }
        }
    }
}

@Reducer
struct SearchCoordinator {
    @ObservableState
    struct State : Equatable {
        static func initialState(currentWorkspace: Workspace? = nil) -> Self {
            Self(
                routes: [.root(.search(.init(currentWorkspace: currentWorkspace)), embedInNavigationView: true)],
                currentWorkspace: currentWorkspace
            )
        }
        var routes: IdentifiedArrayOf<Route<SearchScreen.State>>
        var currentWorkspace : Workspace?
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<SearchScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                
            case let .router(.routeAction(_, action: .search(.buttonTapped(.channelEnter(channel))))):
                state.routes.push(.channel(.initialState(mode: .chat, currentWorkspace: state.currentWorkspace, currentChannel: channel)))
                
            case let .router(.routeAction(_, action: .search(.dmListEnter(dm)))):
                state.routes.push(.dmChat(.init(workspaceCurrent: state.currentWorkspace, roomCurrent: dm)))
                                
            case .router(.routeAction(_, action: .search(.buttonTapped(.profileOpenTapped)))):
                state.routes.push(.profile(.initialState(mode: .me, tabViewMode: false)))
            
            case let .router(.routeAction(_, action: .search(.buttonTapped(.otherProfileButtonTapped(userID))))):
                state.routes.push(.profile(.initialState(mode: .other, userID: userID)))
                
            case .router(.routeAction(_, action: .channel(.router(.routeAction(_, action: .setting(.popupComplete(.channelRemoveOrExit))))))):
                state.routes.goBackToRoot()
                
            case .router(.routeAction(_, action: .channel(.router(.routeAction(_, action: .chat(.goBack)))))), .router(.routeAction(_, action: .dmChat(.goBack))), .router(.routeAction(_, action: .profile(.router(.routeAction(_, action: .profileOther(.goback)))))), .router(.routeAction(_, action: .profile(.router(.routeAction(_, action: .profile(.goBack)))))):
                state.routes.goBack()
                
            default :
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
