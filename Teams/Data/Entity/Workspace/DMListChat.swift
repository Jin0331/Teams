//
//  DMListChat.swift
//  Teams
//
//  Created by JinwooLee on 7/21/24.
//

import Foundation


struct DMListChat : Equatable, Identifiable {
    var roomID : String
    var workspaceID : String
    var createdAt : Date
    var user : ChatUserModel?
    var content : String?
    var currentChatCreatedAt : Date?
    var lastChatCreatedAt : Date?
    var unreadCount : Int
    
    var id : String { return roomID }
    
    var createdAtToString: String {
        guard let currentChatDate = currentChatCreatedAt else {
            return ""
        }

        let calendar = Calendar.current
        if calendar.isDateInToday(currentChatDate) {
            // 오늘일 경우 "PM 11:23" 형태로 포맷팅
            let formatter = DateFormatter()
            formatter.dateFormat = "a hh:mm"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.string(from: currentChatDate)
        } else {
            // 오늘이 아닐 경우 "2024년 5월 20일" 형태로 포맷팅
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월 d일"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: currentChatDate)
        }
    }
}
