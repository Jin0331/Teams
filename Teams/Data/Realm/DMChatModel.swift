//
//  DMChatModel.swift
//  Teams
//
//  Created by JinwooLee on 7/18/24.
//

import Foundation
import RealmSwift

final class DMChatListModel : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var roomID : String
    @Persisted var createdAt : Date
    @Persisted var user : ChatUserModel?
    @Persisted var content : String?
    @Persisted var currentChatCreatedAt : Date?
    @Persisted var lastChatCreatedAt : Date?
    @Persisted var unreadCount : Int // DMChatModel에서 roomID 기준으로 마지막 Date를 가져와서 unreadCount를 체크함
//    @Persisted var dmChat: List<DMChatModel> // DM에서 마지막 date를 가져오기 위한 용도
}

final class DMChatModel : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id : ObjectId
    @Persisted var dmID : String
    @Persisted var roomID : String
    @Persisted var content : String
    @Persisted var createdAt : Date
    @Persisted var files : List<String>
    @Persisted var user : ChatUserModel?
    
    var filesToChatImage : [ChatImage] {
        
        var returnValue : [ChatImage] = []
        
        files.forEach { image in
            
            let imagePath = APIKey.baseURLWithVersion() + image
            returnValue.append(ChatImage(id: dmID, thumbnail: URL(string: imagePath)!, full:  URL(string: imagePath)!))
        }
        
        return returnValue
    }
    
    func toMessage() -> ChatMessage {
        return ChatMessage(uid: _id.stringValue, sender: user!.toUser(), createdAt: createdAt, text: content, images: filesToChatImage)
    }
}

extension DMChatListModel {
    convenience init(from response : DM) {
        self.init()
        roomID = response.roomID
        createdAt = response.createdAtDate!
        user = ChatUserModel(from: response.user)
        unreadCount = 0
    }
}

extension DMChatModel {
    convenience init(from response : DMChat) {
        self.init()
        dmID = response.dmID
        roomID = response.roomID
        content = response.content
        files.append(objectsIn: response.files)
        user = ChatUserModel(from: response.user)
    }
}
