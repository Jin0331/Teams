//
//  ChatUser.swift
//  Teams
//
//  Created by JinwooLee on 7/10/24.
//

import Foundation
import ExyteChat

struct ChatUser: Equatable {
    let uid: String
    let name: String
    let avatar: URL?

    init(uid: String, name: String, avatar: URL? = nil) {
        self.uid = uid
        self.name = name
        self.avatar = avatar
    }
}

extension ChatUser {
    var isCurrentUser: Bool {
        uid == UserDefaultManager.shared.userId!
    }
}

extension ChatUser {
    func toChatUser() -> ExyteChat.User {
        ExyteChat.User(id: uid, name: name, 
                       avatarURL: avatar,
                       isCurrentUser: isCurrentUser,
                       secretKey: APIKey.secretKey.rawValue,
                       accessToken: UserDefaultManager.shared.accessToken)
    }
}

