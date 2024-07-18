//
//  DMChatFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/18/24.
//

import ComposableArchitecture
import Foundation
import Alamofire
import ExyteChat
import RealmSwift

@Reducer
struct DMChatFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var roomCurrent : DM
        var message : [Message] = []
    }
    
    enum Action {
        case onAppear
        case sendMessage(DraftMessage)
        case socket(SocketAction)
        case goBack
    }
    
    enum SocketAction {
        case socketConnect
        case socketReceive
        case socketDisconnectAndGoback
        case socketDisconnectAndGoChannelSetting
        case socketRecevieHandling(ChannelChat)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.socketManager) var socketManager
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
                
            case .socket(.socketDisconnectAndGoback):
//                socketManager.stopAndRemoveSocket()
                return .send(.goBack)
                
            default :
                return .none

            }
        }
    }
}
