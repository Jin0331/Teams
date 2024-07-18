//
//  ChatAttachment.swift
//  Teams
//
//  Created by JinwooLee on 7/10/24.
//

import Foundation
import ExyteChat

struct ChatImage {
    let id: String
    let thumbnail: URL
    let full: URL

    func toChatAttachment() -> Attachment {
        Attachment(
            id: id,
            thumbnail: thumbnail,
            full: full,
            type: .image,
            secretKey: APIKey.secretKey.rawValue,
            accessToken: UserDefaultManager.shared.accessToken
        )
    }
}
