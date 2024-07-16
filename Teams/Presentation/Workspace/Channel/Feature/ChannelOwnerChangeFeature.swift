//
//  ChannelOwnerChangeFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/16/24.
//

import ComposableArchitecture
import Foundation
import Alamofire

@Reducer
struct ChannelOwnerChangeFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var channelCurrent : Channel?
        var channelCurrentMembers : UserList = []
        var viewMode : ViewType = .none
        var popupPresent : CustomPopup?
        
        enum CustomPopup : Equatable {
            case channelOwnerChange(titleText:String, bodyText:String, buttonTitle:String, workspaceID:Workspace, channelId:Channel, twoButton:Bool)
        }
        
        enum ViewType {
            case none
            case change
        }
    }
    
    enum Action : BindableAction {
        case onAppear
        case dismiss
        case listTapped
        case popup(PopupAction)
        case channelMembersResponse(Result<UserList, APIError>)
        case binding(BindingAction<State>)
    }
    
    enum PopupAction {
        case dismissPopupView
        case dismissPopupViewWithError
    }
    
    enum PopupComplete {

    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .onAppear :
                
                guard let workspace = state.workspaceCurrent, let channel = state.channelCurrent else { return .none }
                let workspaceIDDTO = WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: channel.id)
                
                return .run { send in
                    await send(.channelMembersResponse(
                        networkManager.getChannelMemebers(request: workspaceIDDTO)
                    ))
                }
                
            case let .channelMembersResponse(.success(members)):
                
                guard let workspace = state.workspaceCurrent, let channel = state.channelCurrent else { return .none}
                if members.count < 2 {
                    state.viewMode = .none
                    state.popupPresent = .channelOwnerChange(titleText: "채널 관리자 변경 불가", bodyText: "채널 멤버가 없어 관리자 변경을 할 수 없습니다.", buttonTitle: "확인", workspaceID: workspace, channelId: channel, twoButton: false)
                    
                    return .none
                } else {
                    state.viewMode = .change
                    state.channelCurrentMembers = members
                    
                    return .none
                }
                
            case let .channelMembersResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ error")
                return .none
                
            case .popup(.dismissPopupView):
                state.popupPresent = nil
                return .none
                
            case .popup(.dismissPopupViewWithError):
                state.popupPresent = nil
                return .send(.dismiss)
                
            default :
                return .none
            }
        }
    }
}
