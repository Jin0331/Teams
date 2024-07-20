//
//  DMChatUnreadsCount.swift
//  Teams
//
//  Created by JinwooLee on 7/19/24.
//

import Foundation

struct DMChatUnreadsCount : Equatable, Identifiable {
    let roomID : String
    let count : Int
    
    var id : String { return roomID }
}
