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
        case .channelAdd:
                .channelAdd
        case .channelSearch:
                .channelSearch
        }
    }
    
    enum ID: Identifiable {
        case home
        case channelAdd
        case channelSearch
        var id: ID { self }
    }
}
