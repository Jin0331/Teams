//
//  HomeScreen+Identifiable.swift
//  Teams
//
//  Created by JinwooLee on 7/6/24.
//

extension HomeScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .home:
                .home
        case .inviteMember:
                .inviteMember
        case .channelAdd:
                .channelAdd
        case .channelSearch:
                .channelSearch
        case .channelChat:
                .channelChat
        }
    }
    
    enum ID: Identifiable {
        case home
        case inviteMember
        case channelAdd
        case channelSearch
        case channelChat
        var id: ID { self }
    }
}
