//
//  ProfileScreen+Identifiable.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import Foundation

extension ProfileScreen.State : Identifiable {
    var id : ID {
        switch self {
        case .profile:
                .profile
        case .profileEdit:
                .profileEdit
        case .profileOther:
                .profileOther
        }
    }
    
    enum ID : Identifiable {
        case profile
        case profileEdit
        case profileOther
        var id : ID { self }
    }
}
