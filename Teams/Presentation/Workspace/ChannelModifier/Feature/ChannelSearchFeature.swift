//
//  ChannelSearchFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/7/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ChannelSearchFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var channelList : ChannelList = []
        var myChannelList : ChannelList = []
        
        var popupPresent : CustomPopup?
        enum CustomPopup : Equatable {
            case channelEnter(titleText:String, bodyText:String, buttonTitle:String, id:String, twoButton:Bool)
        }
    }
    
    enum Action : BindableAction {
        case dismiss
        case onAppear
        case channeListlResponse(Result<[Channel], APIError>)
        case myChanneListlResponse(Result<[Channel], APIError>)
        case channelListTapped
        case dismissPopupView
        case channelEnter(String)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var utils
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear :
                guard let workspace = state.workspaceCurrent else { return .none }
                return .concatenate([
                    .run { send in
                        await send(.channeListlResponse(networkManager.getChannels(request: WorkspaceIDRequestDTO(workspace_id: workspace.id))))
                    },
                    .run { send in
                        await send(.myChanneListlResponse(networkManager.getMyChannels(request: WorkspaceIDRequestDTO(workspace_id: workspace.id))))
                    }
                ])
                
            //TODO: - Unread API 호출 후, Realm Table 업데이트
            case let .channeListlResponse(.success(response)):
                state.channelList = utils.getSortedChannelList(from: response).filter({ channel in
                    return channel.name != "일반"
                })
                
                return .none
                
            case let .myChanneListlResponse(.success(response)):
                state.myChannelList = utils.getSortedChannelList(from: response)
                
                return .none
                
            case let .channeListlResponse(.failure(error)), let .myChanneListlResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ channeListlResponse error")
                
                return .none
                
                //TODO: - Channel List tapped 했을때 Action
            case .channelListTapped:
                state.popupPresent = .channelEnter(titleText: "채널 참여", bodyText: "정말 이 워크스페이스를 떠나시겠습니까?", buttonTitle: "참여", id: "", twoButton: true)
                return .none
                
            case let .channelEnter(channelID):
                //                state.routes.push(<#T##screen: HomeScreen.State##HomeScreen.State#>)
                print("channel Enter 🌟")
                
                return .none
                
            case .dismissPopupView:
                state.popupPresent = nil
                return .none
                
            default :
                return .none
            }
        }
    }
}
