//
//  ChannelSettingFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/15/24.
//

import ComposableArchitecture
import Foundation
import Alamofire

@Reducer
struct ChannelSettingFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var channelCurrent : Channel?
        var channelCurrentMemebers : UserList?
        var expanded : Bool = true
        
        var popupPresent : CustomPopup?
        enum CustomPopup : Equatable {
            case channelRemove(titleText:String, bodyText:String, buttonTitle:String, workspaceID:Workspace, channelId:Channel, twoButton:Bool)
            case channelExit(titleText:String, bodyText:String, buttonTitle:String, workspaceID:Workspace, channelId:Channel, twoButton:Bool)
        }
    }
    
    enum Action : BindableAction{
        case onAppear
        case goBack
        case popup(PopupAction)
        case popupComplete(PopupComplete)
        case buttonTapped(ButtonTappedAction)
        case networkResponse(NetworkResponse)
        case binding(BindingAction<State>)
    }
    
    enum ButtonTappedAction {
        case channelEditButtonTapped
        case channelExitButtonTapped
        case channelOwnerButtonTapped
        case channelRemoveButtonTapped
    }
    
    enum NetworkResponse {
        case channelSpecificResponse(Result<ChannelSpecific, APIError>)
        case channelRemoveResponse(Result<EmptyResponseDTO, APIError>)
        case channelExitResponse(Result<ChannelList, APIError>)
    }
    
    enum PopupAction {
        case dismissPopupView
        case channelRemove(workspace:Workspace, channel:Channel)
        case channelExit(workspace:Workspace, channel:Channel)
    }
    
    enum PopupComplete {
        case channelRemoveOrExit
        case channelEdit(Channel)
        case channelOwnerChange(Channel)
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                print("ChannelSettingView onAppear 🌟")
                guard let workspace = state.workspaceCurrent, let channel = state.channelCurrent else { return .none}
                return .run { send in
                    await send(.networkResponse(.channelSpecificResponse(
                        networkManager.getSpecificChannel(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: channel.id))
                    )))
                }
            
            case .buttonTapped(.channelRemoveButtonTapped):
                
                guard let workspace = state.workspaceCurrent, let channel = state.channelCurrent else { return .none}
                state.popupPresent = .channelRemove(titleText: "채널 삭제", bodyText: "정말 이 채널을 삭제하시겠습니까? 삭제 시 멤버/채팅 등 채널 내의 모든 정보가 삭제되며 복구할 수 없습니다.", buttonTitle: "삭제", workspaceID: workspace, channelId: channel, twoButton: true)
                
                return .none
                
            case .buttonTapped(.channelExitButtonTapped):
                
                guard let workspace = state.workspaceCurrent, let channel = state.channelCurrent else { return .none}
                
                if channel.ownerID == UserDefaultManager.shared.userId {
                    state.popupPresent = .channelExit(titleText: "채널에서 나가기", bodyText: "회원님은 채널 관리자입니다. 채널 관리자를 다른 멤버로 변경한 후 나갈 수 있습니다.", buttonTitle: "확인", workspaceID: workspace, channelId: channel, twoButton: false)
                } else {
                    state.popupPresent = .channelExit(titleText: "채널에서 나가기", bodyText: "나가기를 하면 채널 목록에서 삭제됩니다.", buttonTitle: "나가기", workspaceID: workspace, channelId: channel, twoButton: true)
                }
                
                return .none
                
            case .buttonTapped(.channelEditButtonTapped):
                guard let channelCurrent = state.channelCurrent else { return .none}
                return .send(.popupComplete(.channelEdit(channelCurrent)))
                
            case .buttonTapped(.channelOwnerButtonTapped):
                guard let channelCurrent = state.channelCurrent else { return .none}
                return .send(.popupComplete(.channelOwnerChange(channelCurrent)))
                
            case let .popup(.channelRemove(workspace, channel)):
                return .run { send in
                    await send(.networkResponse(.channelRemoveResponse(
                           networkManager.removeChannel(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: channel.id))
                       )))
                }
            
            case let .popup(.channelExit(workspace, channel)):
                return .run { send in
                    await send(.networkResponse(.channelExitResponse(
                        networkManager.exitChannel(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: channel.id))
                    )))
                }
            
            case let .networkResponse(.channelSpecificResponse(.success(response))):
                
                state.channelCurrent = response.toChannel
                state.channelCurrentMemebers = response.channelMembers
                
                return .none
                
                
            case .networkResponse(.channelRemoveResponse(.success(_))), .networkResponse(.channelExitResponse(.success(_))):
                return .run { send in
                    await send(.popup(.dismissPopupView))
                    await send(.popupComplete(.channelRemoveOrExit))
                }
                
            case let .networkResponse(.channelRemoveResponse(.failure(error))), let .networkResponse(.channelExitResponse(.failure(error))), let .networkResponse(.channelSpecificResponse(.failure(error))):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ error")
                
                return .none
            
            case .popup(.dismissPopupView):
                state.popupPresent = nil
                return .none
                
            default :
                return .none
            }
        }
    }
}
