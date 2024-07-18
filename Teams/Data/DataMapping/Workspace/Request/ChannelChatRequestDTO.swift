//
//  ChannelChatRequestDTO.swift
//  Teams
//
//  Created by JinwooLee on 7/13/24.
//

import Foundation

struct ChatRequestDTO : Encodable {
    let content : String
    let files : [URL]
}
