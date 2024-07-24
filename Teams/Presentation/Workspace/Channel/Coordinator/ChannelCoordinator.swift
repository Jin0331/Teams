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
        static func initialState(mode : ChannelRootMode = .chat, currentWorkspace: Workspace? = nil, currentChannel : Channel? = nil) -> Self {

            switch mode {
            case .add :
                return Self(
                    routes: [.root(.add(.init()), embedInNavigationView: false)],
                    currentWorkspace : currentWorkspace,
                    currentChannel: currentChannel
                )
            case .chat:
                guard let currentChannel else { return Self(routes: [.root(.search(.init()))])}
                return Self(
                    routes: [.root(.chat(.init(workspaceCurrent: currentWorkspace, channelCurrent: currentChannel)), embedInNavigationView: false)],
                    currentWorkspace : currentWorkspace,
                    currentChannel: currentChannel
                )
            }
        }
                
        var routes: IdentifiedArrayOf<Route<ChannelScreen.State>>
        var currentWorkspace : Workspace?
        var currentChannel : Channel?
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<ChannelScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            
            case let .router(.routeAction(_, action: .chat(.goChannelSetting(worksapceChannel)))):
                state.routes.push(.setting(.init(workspaceCurrent: worksapceChannel.currentWorksapce, channelCurrent: worksapceChannel.currentChannel, channelCurrentMemebers: worksapceChannel.currentChannelMembers)))
                
            case let .router(.routeAction(_, action: .setting(.popupComplete(.channelEdit(channel))))):
                state.routes.presentSheet(.add(.init(viewMode: .edit, currentWorkspace: state.currentWorkspace, currentChannel: channel)))
                
            case let .router(.routeAction(_, action: .setting(.popupComplete(.channelOwnerChange(channel))))):
                state.routes.presentSheet(.owner(.init(workspaceCurrent: state.currentWorkspace, channelCurrent: channel)))
                
            case .router(.routeAction(_, action: .add(.editChannelComplete))), .router(.routeAction(_, action: .owner(.popupComplete(.channelOwnerChange)))):
                return .run { send in
                    await send(.router(.routeAction(id: .setting, action: .setting(.onAppear))))
                }
                
            case .router(.routeAction(_, action: .setting(.goBack))):
                state.routes.goBack()
                
            case .router(.routeAction(_, action: .add(.dismiss))), .router(.routeAction(_, action: .owner(.dismiss))):
                state.routes.dismiss()
                
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
//        case search
        case chat
    }
}
