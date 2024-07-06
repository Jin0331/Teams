//
//  ChannelCreateRequestDTO.swift
//  Teams
//
//  Created by JinwooLee on 7/6/24.
//

import Foundation

struct ChannelCreateRequestDTO : Encodable {
    let name : String
    let description : String?
    let image : Data?
}
