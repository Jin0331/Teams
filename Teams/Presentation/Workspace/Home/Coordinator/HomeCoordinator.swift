//
//  HomeCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/24/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct HomeCoordinatorView : View {
    let store : StoreOf<HomeCoordinator>

    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .home(store):
                HomeView(store: store)
            case let .inviteMember(store):
                WorkspaceInviteView(store: store)
            case let .channelAdd(store):
                ChannelAddView(store: store)
            case let .channelSearch(store):
                ChannelSearchView(store: store)
            case let .channelChat(store):
                ChannelChatView(store: store)
            }
        }
    }


}

@Reducer
struct HomeCoordinator {
    @ObservableState
    struct State : Equatable {
        static func initialState(workspaceCurrent: Workspace? = nil) -> Self {
            Self(
                routes: [.root(.home(.init(workspaceCurrent: workspaceCurrent)), embedInNavigationView: true)],
                currentWorkspace: workspaceCurrent
            )
        }
        var routes: IdentifiedArrayOf<Route<HomeScreen.State>>
        var currentWorkspace : Workspace?
    }

    enum Action {
        case router(IdentifiedRouterActionOf<HomeScreen>)
    }

    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .router(.routeAction(_, action: .home(.channelCreateButtonTapped))):
                state.routes.presentSheet(.channelAdd(.init(currentWorkspace: state.currentWorkspace)))
                
            case .router(.routeAction(_, action: .home(.inviteMemberButtonTapped))):
                state.routes.presentSheet(.inviteMember(.init(currentWorkspace: state.currentWorkspace)))
                
            case .router(.routeAction(_, action: .home(.channelSearchButtonTapped))):
                state.routes.presentCover(.channelSearch(.init(workspaceCurrent: state.currentWorkspace)))
                
            case .router(.routeAction(_, action: .channelAdd(.dismiss))), .router(.routeAction(_, action: .channelSearch(.dismiss))), .router(.routeAction(_, action: .inviteMember(.dismiss))):
                state.routes.dismiss()
                
            case .router(.routeAction(_, action: .channelAdd(.createChannelComplete))):
                return .send(.router(.routeAction(id: .home, action: .home(.onAppear))))
                
            case .router(.routeAction(_, action: .inviteMember(.inviteComplete))):
                state.routes.dismiss()
                return .send(.router(.routeAction(id: .home, action: .home(.onAppear))))
                
            case let .router(.routeAction(_, action: .channelSearch(.channelEnter(channelID)))):
                print("channel Enter 🌟", channelID)
                state.routes.dismiss()
                state.routes.push(.channelChat(.init()))
                
                
            default :
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
