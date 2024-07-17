//
//  DMScreen+Identifiable.swift
//  Teams
//
//  Created by JinwooLee on 7/17/24.
//

import Foundation

extension DMScreen.State : Identifiable {
    var id : ID {
        switch self {
        case .dmList:
                .dmList
        case .inviteMember:
                .inviteMember
        }
    }
    
    enum ID : Identifiable {
        case dmList
        case inviteMember
        var id : ID { self }
    }
}
