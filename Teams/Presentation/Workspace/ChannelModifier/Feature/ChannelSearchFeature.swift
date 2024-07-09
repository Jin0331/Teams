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
            case channelEnter(titleText:String, bodyText:String, buttonTitle:String, id:Channel, twoButton:Bool)
        }
    }
    
    enum Action : BindableAction {
        case dismiss
        case onAppear
        case channeListlResponse(Result<[Channel], APIError>)
        case myChanneListlResponse(Result<[Channel], APIError>)
        case channelListTapped(Channel)
        case dismissPopupView
        case channelEnter(Channel)
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
                        await send(.channeListlResponse(networkManager.getChannels(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: ""))))
                    },
                    .run { send in
                        await send(.myChanneListlResponse(networkManager.getMyChannels(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: ""))))
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
            case let .channelListTapped(channel):
                
                if state.myChannelList.contains(where: { $0.id == channel.id }) {
                    return .send(.channelEnter(channel))
                }
                
                state.popupPresent = .channelEnter(titleText: "채널 참여", bodyText: "[\(channel.name)] 채널에 참여하시겠습니까?", buttonTitle: "참여", id: channel, twoButton: true)
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
