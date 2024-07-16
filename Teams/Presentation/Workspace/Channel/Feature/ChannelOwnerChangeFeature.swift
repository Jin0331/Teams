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
        
        var popupPresent : CustomPopup?
        enum CustomPopup : Equatable {
            case channelRemove(titleText:String, bodyText:String, buttonTitle:String, workspaceID:Workspace, channelId:Channel, twoButton:Bool)
        }
    }
    
    enum Action : BindableAction {
        case onAppear
        case dismiss
        case listTapped
        case popup(PopupAction)
        case binding(BindingAction<State>)
    }
    
    enum PopupAction {
        case dismissPopupView
        case channelRemove(workspace:Workspace, channel:Channel)
        case channelExit(workspace:Workspace, channel:Channel)
    }
    
    enum PopupComplete {
        case channelRemoveOrExit
        case channelEdit(Channel)
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .onAppear :
                
                print(state.workspaceCurrent, state.channelCurrent)
                
                return .none
                
            default :
                return .none
            }
        }
    }
}
