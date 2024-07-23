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
    
    func deleteALL() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(error, "- Delete ALL error")
        }
    }
    
    func upsertChannelChat(chatResponse : ChannelChat)  {
        do {
            try realm.write {
                realm.create(ChannelChatModel.self, 
                             value: ["channelID":chatResponse.channelID,
                                     "channelName":chatResponse.channelName,
                                     "chatID":chatResponse.chatID,
                                     "content": chatResponse.content,
                                     "createdAt": chatResponse.createdAtDate!,
                                     "files" : chatResponse.files,
                                     "user" : chatResponse.user], update: .modified) }
        } catch {
            print(error)
        }
    }
    
    func upsertChannelList(channelResponse : Channel, workspaceID : String) {
        
        do {
            try realm.write {
                realm.create(ChannelChatListModel.self,
                             value : [ "channelID": channelResponse.channelID,
                                       "workspaceID": workspaceID,
                                       "channelName": channelResponse.name,
                                       "ownerID": channelResponse.ownerID,
                                       "coverImage": channelResponse.coverImage,
                                       "desc" : channelResponse.description,
                                       "createdAt": channelResponse.createdAtDate!
                                     ], update: .modified)
            }
        } catch {
            print(error)
        }
    }
    
    
    func upsertChannelListLastChatCreatedAt(channelID : String , lastChatCreatedAt : Date?) {
        
        do {
            try realm.write {
                realm.create(ChannelChatListModel.self,
                             value : ["channelID": channelID,
                                      "lastChatCreatedAt" : lastChatCreatedAt
                                     ], update: .modified)
            }
        } catch {
            print(error)
        }
    }
    
    func upsertCurrentChannelListContentWithCreatedAt(channelID : String, currentChatCreatedAt : Date?, lastChatUser : String?) {
        do {
            try realm.write {
                realm.create(ChannelChatListModel.self,
                             value: ["channelID":channelID,
                                     "currentChatCreatedAt":currentChatCreatedAt,
                                     "lastChatUser":lastChatUser
                                    ], update: .modified)
                
            }
        } catch {
            print(error)
        }
    }
    
    
    func upsertDMList(dmResponse : DM, workspaceID : String) {
        
        do {
            try realm.write {
                realm.create(DMChatListModel.self, 
                             value : ["roomID": dmResponse.roomID,
                                      "workspaceID" : workspaceID,
                                      "createdAt": dmResponse.createdAtDate!,
                                      "user": ChatUserModel(from: dmResponse.user)
                                     ], update: .modified)
            }
        } catch {
            print(error)
        }
    }
    
    func upsertDMListLastChatCreatedAt(roomID : String , lastChatCreatedAt : Date?) {
        
        do {
            try realm.write {
                realm.create(DMChatListModel.self,
                             value : ["roomID": roomID,
                                      "lastChatCreatedAt" : lastChatCreatedAt
                                     ], update: .modified)
            }
        } catch {
            print(error)
        }
    }
    
    func upsertCurrentDMListContentWithCreatedAt(roomID : String, content : String?, currentChatCreatedAt : Date?, lastChatUser : String?) {
        do {
            try realm.write {
                realm.create(DMChatListModel.self,
                             value: ["roomID":roomID,
                                     "content":content,
                                     "currentChatCreatedAt":currentChatCreatedAt,
                                     "lastChatUser":lastChatUser
                                    ], update: .modified)
                
            }
        } catch {
            print(error)
        }
    }
    
    func fetchChannelChatLastDate(channelID : String) -> Date? {
        let table = realm.objects(ChannelChatModel.self).where {
            $0.channelID == channelID
        }

        if let latestMessage = table.sorted(byKeyPath: "createdAt", ascending: false).first {
            return latestMessage.createdAt
        } else {
            return nil
        }
    }
    
    func fetchChannelExyteMessage(channelID : String) -> [Message] {
        let table = realm.objects(ChannelChatModel.self).where {
            $0.channelID == channelID
        }
        
        return table.map { row in
            row.toMessage().toExyteMessage()
        }
    }
    
    func fetchAllDMChatList(workspaceID : String) -> [DMListChat] {
        
        var list : [DMListChat] = []
        
        let table = realm.objects(DMChatListModel.self).where {
            $0.workspaceID == workspaceID
        }
        
        table.forEach { dmChatListModel in
            list.append(dmChatListModel.toDMChatList)
        }
        
        return list
    }
    
    func fetchDMChatLastDate(roomID : String) -> Date? {
        let table = realm.objects(DMChatModel.self).where {
            $0.roomID == roomID
        }

        if let latestMessage = table.sorted(byKeyPath: "createdAt", ascending: false).first {
            return latestMessage.createdAt
        } else {
            return nil
        }
    }
    
    func fetchDMExyteMessage(roomID : String) -> [Message] {
        let table = realm.objects(DMChatModel.self).where {
            $0.roomID == roomID
        }
        
        return table.map { row in
            row.toMessage().toExyteMessage()
        }
    }
    
    func upsertChannelUnreadsCount(channelID : String, unreadCount : Int) {
        do {
            try realm.write {
                realm.create(ChannelChatListModel.self,
                             value: ["channelID":channelID,
                                     "unreadCount":unreadCount
                                    ], update: .modified)
            }
        } catch {
            print(error)
        }
    }
    
    func upsertDMUnreadsCount(roomID : String, unreadCount : Int) {
        do {
            try realm.write {
                realm.create(DMChatListModel.self,
                             value: ["roomID":roomID,
                                     "unreadCount":unreadCount
                                    ], update: .modified)
            }
        } catch {
            print(error)
        }
    }
    
    func fetchDMListCreateDate(roomID : String) -> Date {
        guard let table = realm.object(ofType: DMChatListModel.self, forPrimaryKey: roomID) else { return Date()}
        
        return table.createdAt
    }
    
    func fetchChannelListChatUser(channelID : String) -> String? {
        guard let table = realm.object(ofType: ChannelChatListModel.self, forPrimaryKey: channelID) else { return nil }
        
        return table.lastChatUser
    }
    
    func fetchDMListChatUser(roomID : String) -> String? {
        guard let table = realm.object(ofType: DMChatListModel.self, forPrimaryKey: roomID) else { return nil }
        
        return table.lastChatUser
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
