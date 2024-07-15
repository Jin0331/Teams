//
//  User.swift
//  Teams
//
//  Created by JinwooLee on 7/5/24.
//

import Foundation

struct User : Equatable, Identifiable {
    let userID, email, nickname, profileImage : String
    
    var id : String { return userID }
}

extension User {
    var profileImageToUrl : URL {
        return URL(string: APIKey.baseURLWithVersion() + profileImage)!
    }
}

typealias UserList = [User]
