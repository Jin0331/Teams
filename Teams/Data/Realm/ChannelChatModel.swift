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
    
    //TODO: - Header가 포함된 URL
    
    var filesToChatImage : [ChatImage] {
        
        var returnValue : [ChatImage] = []
        
        files.forEach { image in
            
            let imagePath = APIKey.baseURLWithVersion() + image
            returnValue.append(ChatImage(id: chatID, thumbnail: URL(string: imagePath)!, full:  URL(string: imagePath)!))
        }
        
        return returnValue
    }
    
    func toMessage() -> ChatMessage {
        return ChatMessage(uid: _id.stringValue, sender: user!.toUser(), createdAt: createdAt, text: content, images: filesToChatImage)
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
        if !profileImage.isEmpty {
            return URL(string: APIKey.baseURLWithVersion() + profileImage)!
        } else {
            return URL(string: APIKey.defaultProfileImage())!
        }
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
