//
//  ChannelAddFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/6/24.
//

import ComposableArchitecture
import Foundation
import Alamofire

@Reducer
struct ChannelAddFeature {
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var viewMode : ViewType = .create
        var currentWorkspace : Workspace?
        var currentChannel : Channel?
        var channelName : String = ""
        var channelNameValid : Bool = false
        var channelDescription : String = ""
        var createButton : Bool = false
        var toastPresent : ToastMessage?
        
        enum ToastMessage : String, Hashable, CaseIterable {
            case duplicate = "워크스페이스에 이미 있는 채널 이름입니다. 다른 이름을 입력해주세요."
        }
        
        enum ViewType {
            case create
            case edit
        }
    }
    
    enum Action : BindableAction {
        case binding(BindingAction<State>)
        case createButtonActive
        case createButtonTapped
        case createChannelResponse(Result<Channel, APIError>)
        case dismiss
        case createChannelComplete
        case editChannelComplete
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var validTest
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.channelName):
                return .send(.createButtonActive)
                
            case .createButtonActive:
                if !state.channelName.isEmpty {
                    state.createButton = true
                } else {
                    state.createButton = false
                }
                return .none
            
            case .createButtonTapped:
                state.channelNameValid = validTest.isValidNickname(state.channelName)
                
                if let field = [state.channelNameValid].firstIndex(of: false) {
                    state.toastPresent = State.ToastMessage.allCases[field]
                    return .none
                }
                
                guard let workspace = state.currentWorkspace else { return .none }
                let createChannelRequest = ChannelCreateRequestDTO(name: state.channelName,
                                                                       description: state.channelDescription,
                                                                       image: nil)

                return .run { [viewMode = state.viewMode, currentChannel = state.currentChannel] send in
                    
                    if viewMode == .create {
                        await send(.createChannelResponse(
                            networkManager.createChannel(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: "", room_id: ""), query: createChannelRequest)
                        ))
                    } else { // edit mode
                        if let currentChannel {
                            await send(.createChannelResponse(
                                networkManager.editChannel(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: currentChannel.channelID, room_id: ""), query: createChannelRequest)
                            ))
                        }
                    }
                }
                
            case let .createChannelResponse(.success(response)):
                
                dump(response)
                
                if state.viewMode == .create {
                    return .concatenate([.send(.createChannelComplete), .send(.dismiss)])
                } else {
                    return .concatenate([.send(.editChannelComplete), .send(.dismiss)])
                }
                
            case let .createChannelResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                
                if case .E12 = errorType {
                    state.toastPresent = State.ToastMessage.duplicate
                }
                
                return .none

                
            default :
                return .none
            }
        }
    }
}

