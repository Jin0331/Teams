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
            case channelOwnerChange(titleText:String, bodyText:String, buttonTitle:String, workspaceID:Workspace, channelId:Channel, member:User?, twoButton:Bool)
        }
        
        enum ViewType {
            case none
            case change
        }
    }
    
    enum Action : BindableAction {
        case onAppear
        case dismiss
        case listTapped(User)
        case networkResponse(NetworkResponse)
        case popup(PopupAction)
        case popupComplete(PopupComplete)
        case binding(BindingAction<State>)
    }

    enum NetworkResponse {
        case channelMembersResponse(Result<UserList, APIError>)
        case channelOwnerChangeResponse(Result<Channel, APIError>)
    }
    
    enum PopupAction {
        case dismissPopupView
        case dismissPopupViewWithError
        case channelChangeOwner(workspace:Workspace, channel:Channel, memeber:User)
    }
    
    enum PopupComplete {
        case channelOwnerChange
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
                    await send(.networkResponse(.channelMembersResponse(
                        networkManager.getChannelMemebers(request: workspaceIDDTO)
                    )))
                }
                
            case let .listTapped(user):
                state.viewMode = .change
                guard let workspace = state.workspaceCurrent, let channel = state.channelCurrent else { return .none }
                
                state.popupPresent = .channelOwnerChange(titleText: "\(user.nickname) 님을 관리자로 지정하시겠습니까?", bodyText: "채널 관리자는 다음과 같은 권한이 있습니다.\n\n-채널 이름 또는 설명 변경\n-채널 삭제", buttonTitle: "확인", workspaceID: workspace, channelId: channel, member: user, twoButton: true)
                
                return .none
                
            case .popup(.dismissPopupView), .popup(.dismissPopupViewWithError):
                state.popupPresent = nil
                return .send(.dismiss)

            
            case let .popup(.channelChangeOwner(workspace, channel, member)):
                return .run { send in
                    await send(.networkResponse(.channelOwnerChangeResponse(
                        networkManager.changeChannelOwner(request : WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: channel.id),
                                                          body : ChannelOwnershipRequestDTO(owner_id: member.userID))
                    )))
                }
                
            case let .networkResponse(.channelMembersResponse(.success(members))):
                
                guard let workspace = state.workspaceCurrent, let channel = state.channelCurrent else { return .none}
                if members.count < 2 {
                    state.viewMode = .none
                    state.popupPresent = .channelOwnerChange(titleText: "채널 관리자 변경 불가", bodyText: "채널 멤버가 없어 관리자 변경을 할 수 없습니다.", buttonTitle: "확인", workspaceID: workspace, channelId: channel, member: nil, twoButton: false)
                    
                    return .none
                } else {
                    state.viewMode = .change
                    state.channelCurrentMembers = members
                    
                    return .none
                }
                
            case .networkResponse(.channelOwnerChangeResponse(.success(_))):
                return .run { send in
                    await send(.popupComplete(.channelOwnerChange))
                    await send(.popup(.dismissPopupView))
                }
                
            case let .networkResponse(.channelMembersResponse(.failure(error))):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ error")
                return .none
                
            default :
                return .none
            }
        }
    }
}
