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
    @Persisted var workspaceID : String
    @Persisted var createdAt : Date
    @Persisted var user : ChatUserModel?
    @Persisted var content : String?
    @Persisted var currentChatCreatedAt : Date?
    @Persisted var lastChatCreatedAt : Date?
    @Persisted var unreadCount : Int
    
    var toDMChatList : DMListChat {
        
        print(unreadCount)
        
        return .init(roomID: roomID,
                     workspaceID: workspaceID,
                     createdAt: createdAt,
                     user: user,
                     content: content,
                     currentChatCreatedAt: currentChatCreatedAt,
                     lastChatCreatedAt: lastChatCreatedAt,
                     unreadCount: unreadCount)
    }
    
    var createdAtToString: String {
        guard let currentChatDate = currentChatCreatedAt else {
            return ""
        }

        let calendar = Calendar.current
        if calendar.isDateInToday(currentChatDate) {
            // 오늘일 경우 "PM 11:23" 형태로 포맷팅
            let formatter = DateFormatter()
            formatter.dateFormat = "a hh:mm"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.string(from: currentChatDate)
        } else {
            // 오늘이 아닐 경우 "2024년 5월 20일" 형태로 포맷팅
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월 d일"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: currentChatDate)
        }
    }
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
