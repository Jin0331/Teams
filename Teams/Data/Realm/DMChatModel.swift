//
//  DMChatModel.swift
//  Teams
//
//  Created by JinwooLee on 7/18/24.
//

import Foundation
import RealmSwift

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
        return ChatMessage(uid: dmID, sender: user!.toUser(), createdAt: createdAt, text: content, images: filesToChatImage)
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
