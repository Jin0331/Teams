//
//  Repository.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import Foundation
import RealmSwift

final class Repository {
    
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
        
//        do {
//            try realm.write {
//                realm.create(ChannelChatModel.self, value: ["roomID":chatResponse.roomID,
//                                                             "createdAt":chatResponse.createdAt.toDate()!,
//                                                             "updatedAt":chatResponse.updatedAt.toDate()!,
//                                                             "participants": chatResponse.participants.map(RealmSender.init),
//                                                             "lastChat": chatResponse.lastChat.map(RealmLastChat.init) ?? nil
//                                                ],
//                             update: .modified) }
//        } catch {
//            print(error)
//        }
    }
    
}
