//
//  ChannelChatRequestDTO.swift
//  Teams
//
//  Created by JinwooLee on 7/13/24.
//

import Foundation

struct ChannelChatRequestDTO : Encodable {
    let content : String
    let files : [URL]
}
