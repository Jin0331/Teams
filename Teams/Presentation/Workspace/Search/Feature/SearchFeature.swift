//
//  SearchFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SearchFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var currentWorkspace : Workspace?
        var profileImage : URL?
        var channels : ChannelList = []
        var members : UserList = []
        var searchKeyword : String = ""
        var myChannelList : ChannelList = []
        var popupPresent : CustomPopup?
    }
    
    enum Action : BindableAction {
        case onAppear
        case dismiss
        case dismissPopupView
        case networkResponse(NetworkResponse)
        case binding(BindingAction<State>)
        case buttonTapped(ButtonTapped)
    }
    
    enum ButtonTapped {
        case channelListTapped(Channel)
        case channelEnter(Channel)
    }
    
    enum NetworkResponse {
        case profile(Result<Profile, APIError>)
        case workspaceSearch(Result<Workspace, APIError>)
        case myChanneListlResponse(Result<[Channel], APIError>)
    }
    
    enum ID: Hashable {
        case debounce, throttle
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var utilitiesFunction
    
    var body : some ReducerOf<Self> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            
            switch action {
            
            case .onAppear:
                guard let currentWorkspace = state.currentWorkspace else { return .none }
                return .run { send in
                    await send(.networkResponse(.profile(
                        networkManager.getMyProfile()
                    )))
                    
                    await send(.networkResponse(.myChanneListlResponse(networkManager.getMyChannels(
                        request: WorkspaceIDRequestDTO(workspace_id: currentWorkspace.id, channel_id: "", room_id: ""))
                    )))
                }
                
            case .binding(\.searchKeyword):
                
                guard let currentWorkspace = state.currentWorkspace else { return .none}

                return .run { [keyword = state.searchKeyword] send in
                    await send(.networkResponse(.workspaceSearch(
                        networkManager.getWorkspaceSearch(request: WorkspaceIDRequestDTO(workspace_id: currentWorkspace.workspaceID, channel_id: "", room_id: ""), query: keyword)
                    )))
                }
                .debounce(id: ID.debounce,
                          for: 1.5,
                          scheduler: DispatchQueue.main)
                .animation(.smooth)
                
            case let .buttonTapped(.channelListTapped(channel)):
                if state.myChannelList.contains(where: { $0.id == channel.id }) {
                    return .send(.buttonTapped(.channelEnter(channel)))
                }
                
                state.popupPresent = .channelEnter(titleText: "채널 참여", bodyText: "[\(channel.name)] 채널에 참여하시겠습니까?", buttonTitle: "참여", id: channel, twoButton: true)
                return .none
            
            case let .networkResponse(.profile(.success(myProfile))):
                state.profileImage = myProfile.profileImageToUrl
                
                return .none
                
            case let .networkResponse(.workspaceSearch(.success(search))):
                
                if !search.channels.isEmpty {
                    state.channels = search.channels
                } else {
                    state.channels = []
                }
                
                if !search.workspacMembers.isEmpty {
                    state.members = search.workspacMembers
                } else {
                    state.members = []
                }
    
                return .none
                
            case let .networkResponse(.myChanneListlResponse(.success(response))):
                state.myChannelList = utilitiesFunction.getSortedChannelList(from: response)
                
                return .none

            
            case let .networkResponse(.profile(.failure(error))), let .networkResponse(.myChanneListlResponse(.failure(error))):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ error")
                return .none
                
            case let .networkResponse(.workspaceSearch(.failure(error))):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ error")
                state.channels = []
                state.members = []
                
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

extension SearchFeature {
    enum CustomPopup : Equatable {
        case channelEnter(titleText:String, bodyText:String, buttonTitle:String, id:Channel, twoButton:Bool)
    }
}
