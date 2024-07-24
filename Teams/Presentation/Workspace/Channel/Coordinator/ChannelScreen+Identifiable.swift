//
//  ChannelScreen+Identifiable.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import Foundation

extension ChannelScreen.State : Identifiable {
    
    var id : ID {
        switch self {
        case .add:
                .add
        case .search:
                .search
        case .chat:
                .chat
        case .setting:
                .setting
        case .owner:
                .owner
        }
    }
    
    enum ID : Identifiable {
        case add
        case search
        case chat
        case setting
        case owner
        
        var id : ID {self}
    }
}
