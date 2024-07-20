//
//  DMChatUnreadCountResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 7/19/24.
//

import Foundation

struct DMChatUnreadCountResponseDTO : Decodable {
    let room_id : String
    let count : Int
}

extension DMChatUnreadCountResponseDTO {
    func toDomain() -> DMChatUnreadsCount {
        return .init(roomID: room_id, count: count)
    }
}
