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
        
        var popupPresent : CustomPopup?
        var popupPresentBool : Bool = false
        enum CustomPopup : Equatable {
            case channelRemove(titleText:String, bodyText:String, buttonTitle:String, workspaceID:Workspace, channelId:Channel, twoButton:Bool)
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
        case channelRemoveResponse(Result<EmptyResponseDTO, APIError>)
    }
    
    enum PopupAction {
        case dismissPopupView
        case channelRemove(workspace:Workspace, channel:Channel)
        
    }
    
    enum PopupComplete {
        case channelRemove
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                
                print(state.workspaceCurrent, state.channelCurrent, state.channelCurrentMemebers)
                
                return .none
            
            case .buttonTapped(.channelRemoveButtonTapped):
                
                guard let workspace = state.workspaceCurrent, let channel = state.channelCurrent else { return .none}
                
                state.popupPresentBool = true
                state.popupPresent = .channelRemove(titleText: "채널 삭제", bodyText: "정말 이 채널을 삭제하시겠습니까? 삭제 시 멤버/채팅 등 채널 내의 모든 정보가 삭제되며 복구할 수 없습니다.", buttonTitle: "참여", workspaceID: workspace, channelId: channel, twoButton: true)
                
                return .none
                
            case let .popup(.channelRemove(workspace, channel)):
                return .run { send in
                    await send(.networkResponse(.channelRemoveResponse(
                           networkManager.removeChannel(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: channel.id))
                       )))
                }
            
            case .networkResponse(.channelRemoveResponse(.success(_))):
                return .run { send in
                    await send(.popup(.dismissPopupView))
                    await send(.popupComplete(.channelRemove))
                }
                
            case let .networkResponse(.channelRemoveResponse(.failure(error))):
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
