//
//  ChannelChatModel.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import Foundation
import RealmSwift

final class ChannelChatModel : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id : ObjectId
    @Persisted var channelID : String
    @Persisted var channelName : String
    @Persisted var chatID : String
    @Persisted var content : String
    @Persisted var createdAt : Date
    @Persisted var files : List<String>
    @Persisted var user : ChatUserModel?
    
    func toMessage() -> ChatMessage {
        return ChatMessage(uid: chatID, sender: user!.toUser(), createdAt: createdAt, text: content, images: [])
    }
}

extension ChannelChatModel {
    convenience init(from response : ChannelChat) {
        self.init()
        channelID = response.channelID
        channelName = response.channelName
        chatID = response.chatID
        content = response.content
        createdAt = response.createdAtDate!
        files.append(objectsIn: response.files)
        user = ChatUserModel(from: response.user)
    }
}

final class ChatUserModel : EmbeddedObject, ObjectKeyIdentifiable {
    @Persisted var userID : String
    @Persisted var email : String
    @Persisted var nickname : String
    @Persisted var profileImage : String
    
    var profileImageToUrl : URL {
        return URL(string: APIKey.baseURLWithVersion() + profileImage)!
    }
    
    func toUser() -> ChatUser {
        return ChatUser(uid: userID, name: nickname, avatar: profileImageToUrl)
    }
}

extension ChatUserModel {
    convenience init(from response : User) {
        self.init()
        userID = response.id
        email = response.email
        nickname = response.nickname
        profileImage = response.profileImage
    }
}
