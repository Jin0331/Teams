//
//  SearchScreen+Identifiable.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import Foundation

extension SearchScreen.State : Identifiable {
    var id : ID {
        switch self {
        case .search:
                .search
        case .channel:
                .channel
        case .dmChat:
                .dmChat
        case .profile:
                .profile
        }
    }
    
    enum ID :Identifiable {
        case search
        case channel
        case dmChat
        case profile
        
        var id: ID { self }
    }
}
