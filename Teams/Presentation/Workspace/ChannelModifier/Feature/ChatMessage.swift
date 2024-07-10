//
//  ChatMessage.swift
//  Teams
//
//  Created by JinwooLee on 7/10/24.
//

import Foundation
import ExyteChat

struct ChatMessage {
    let uid: String
    let sender: ChatUser
    let createdAt: Date
    
    let text: String
    let images: [ChatImage]
}

extension ChatMessage {
    func toExyteMessage() -> ExyteChat.Message {
        ExyteChat.Message(
            id: uid,
            user: sender.toChatUser(),
            createdAt: createdAt,
            text: text,
            attachments: images.map { $0.toChatAttachment()
            }
        )
    }
}

