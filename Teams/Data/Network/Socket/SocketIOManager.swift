//
//  SocketIOManager.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import Foundation
import SocketIO
import Combine

final class SocketIOManager {
    var manager : SocketManager
    var socket : SocketIOClient
    let baseURL = URL(string: APIKey.baseURLWithVersion())!
    var receivedChatData = PassthroughSubject<ChannelChat, Never>()
    var channelID : String
    
    init(channelID : String) {
        
        self.channelID = "/ws-channel-" + channelID
        
        manager = SocketManager(socketURL: baseURL, config: [.log(false), .compress])
        socket = manager.socket(forNamespace: self.channelID)
    }
    
    func receiveData() {
        socket.on(clientEvent: .connect) { data, ack in
            print("socket connected", data, ack)
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("socket disconnected")
        }
        
        // [Any] > Data > Struct
        socket.on("channel") { [weak self] dataArray, ack in
            guard let self = self else { return }
            
            if let data = dataArray.first {
                
                do {
                    let result = try JSONSerialization.data(withJSONObject: data)
                    let decodedData = try JSONDecoder().decode(ChannelChatResponseDTO.self, from: result)
                    
                    receivedChatData.send(decodedData.toDomain())
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    func establishConnection() {
        socket.connect()
    }
    
    func leaveConnection() {
        socket.disconnect()
    }
}

