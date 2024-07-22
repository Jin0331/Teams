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
            case let .channelSetting(store):
                ChannelSettingView(store: store)
            case let .channelOwnerChange(store):
                ChannelOwnerChangeView(store: store)
            case let .dmChat(store):
                DMChatView(store: store)
            case let .profile(store):
                ProfileCoordinatorView(store: store)
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
            case .router(.routeAction(_, action: .home(.buttonTapped(.channelCreateButtonTapped)))):
                state.routes.presentSheet(.channelAdd(.init(viewMode: .create, currentWorkspace: state.currentWorkspace)))
            
            case let .router(.routeAction(_, action: .channelSetting(.popupComplete(.channelEdit(channel))))):
                state.routes.presentSheet(.channelAdd(.init(viewMode: .edit, currentWorkspace: state.currentWorkspace, currentChannel: channel)))
            
            case let .router(.routeAction(_, action: .channelSetting(.popupComplete(.channelOwnerChange(channel))))):
                state.routes.presentSheet(.channelOwnerChange(.init(workspaceCurrent: state.currentWorkspace, channelCurrent: channel)))
            
            case .router(.routeAction(_, action: .home(.buttonTapped(.inviteMemberButtonTapped)))):
                state.routes.presentSheet(.inviteMember(.init(currentWorkspace: state.currentWorkspace)))
                
            case .router(.routeAction(_, action: .home(.buttonTapped(.channelSearchButtonTapped)))):
                state.routes.presentCover(.channelSearch(.init(workspaceCurrent: state.currentWorkspace)))
                
            case .router(.routeAction(_, action: .channelAdd(.dismiss))), .router(.routeAction(_, action: .channelSearch(.dismiss))), 
                    .router(.routeAction(_, action: .inviteMember(.dismiss))), .router(.routeAction(_, action: .channelOwnerChange(.dismiss))):
                state.routes.dismiss()
                
            case .router(.routeAction(_, action: .channelAdd(.createChannelComplete))):
                return .send(.router(.routeAction(id: .home, action: .home(.onAppear))))
                
            case .router(.routeAction(_, action: .channelAdd(.editChannelComplete))), .router(.routeAction(_, action: .channelOwnerChange(.popupComplete(.channelOwnerChange)))):
                return .send(.router(.routeAction(id: .channelSetting, action: .channelSetting(.onAppear))))
                
            case .router(.routeAction(_, action: .inviteMember(.inviteComplete))):
                state.routes.dismiss()
                return .send(.router(.routeAction(id: .home, action: .home(.onAppear))))
                
            case let .router(.routeAction(_, action: .channelSearch(.channelEnter(channel)))):
                return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
                    $0.dismiss()
                    $0.push(.channelChat(.init(workspaceCurrent: state.currentWorkspace, channelCurrent: channel)))
                }
            
            case let .router(.routeAction(_, action: .home(.channelEnter(channel)))):
                state.routes.push(.channelChat(.init(workspaceCurrent: state.currentWorkspace, channelCurrent: channel)))
                
            case .router(.routeAction(_, action: .channelChat(.goBack))), .router(.routeAction(_, action: .channelSetting(.goBack))), .router(.routeAction(_, action: .dmChat(.goBack))):
                state.routes.goBack()
                
            case let .router(.routeAction(_, action: .channelChat(.goChannelSetting(worksapceChannel)))):
                state.routes.push(.channelSetting(.init(workspaceCurrent: worksapceChannel.currentWorksapce, channelCurrent: worksapceChannel.currentChannel, channelCurrentMemebers: worksapceChannel.currentChannelMembers)))
                
            case .router(.routeAction(_, action: .channelSetting(.popupComplete(.channelRemoveOrExit)))):
                state.routes.goBackToRoot()
            
            case let .router(.routeAction(_, action: .home(.dmListEnter(dm)))):
                state.routes.push(.dmChat(.init(workspaceCurrent: state.currentWorkspace, roomCurrent: dm)))
            
            default :
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
