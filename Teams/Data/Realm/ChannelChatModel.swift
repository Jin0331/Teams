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
    @Persisted var channelID : Int
    @Persisted var channelName : String
    @Persisted var chatID : Int
    @Persisted var content : String
    @Persisted var createdAt : String
    @Persisted var files : List<String>
    @Persisted var user : UserModel
}

extension ChannelChatModel {
    convenience init(from response : ChannelChat) {
        self.init()
        channelID = response.channelID
        channelName = response.channelName
        chatID = response.chatID
        content = response.content
        createdAt = response.createdAt
        files.append(objectsIn: response.files)
        user = UserModel(from: response.user)
    }
}
