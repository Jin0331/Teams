//
//  Repository.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import Foundation
import ExyteChat
import ComposableArchitecture
import RealmSwift

final class RealmRepository {
    
    private let realm = try! Realm()
    
    func realmLocation() { print("현재 Realm 위치 🌼 - ",realm.configuration.fileURL!) }
    
    //MARK: - CREATE
    // CREATE
    func createTable<T:Object>(_ item : T) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print(error, "- Create Error")
        }
    }
    
    func upsertChannelChatList(chatResponse : ChannelChat)  {
        
        do {
            try realm.write {
                realm.create(ChannelChatModel.self, value: ["channelID":chatResponse.channelID,
                                                             "channelName":chatResponse.channelName,
                                                             "chatID":chatResponse.chatID,
                                                             "content": chatResponse.content,
                                                             "createdAt": chatResponse.createdAtDate!,
                                                             "files" : chatResponse.files,
                                                             "user" : chatResponse.user
                                                ],
                             update: .modified) }
        } catch {
            print(error)
        }
    }
    
    func fetchChatLastDate(channelID : String) -> Date? {
        let table = realm.objects(ChannelChatModel.self).where {
            $0.channelID == channelID
        }

        if let latestMessage = table.sorted(byKeyPath: "createdAt", ascending: false).first {
            return latestMessage.createdAt
        } else {
            return nil
        }
    }
    
    func fetchExyteMessage(channelID : String) -> [Message] {
        let table = realm.objects(ChannelChatModel.self).where {
            $0.channelID == channelID
        }
        
        return table.map { row in
            row.toMessage().toExyteMessage()
        }
        
    }
}

private enum RealmRepositoryKey : DependencyKey {
    static var liveValue: RealmRepository = RealmRepository()
}

extension DependencyValues {
    var realmRepository : RealmRepository {
        get { self[RealmRepositoryKey.self] }
        set { self[RealmRepositoryKey.self] = newValue }
    }
}
