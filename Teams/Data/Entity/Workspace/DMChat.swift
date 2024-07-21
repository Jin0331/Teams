//
//  DMChat.swift
//  Teams
//
//  Created by JinwooLee on 7/18/24.
//

import Foundation

struct DMChat : Equatable, Identifiable {
    let dmID : String
    let roomID : String
    let content : String
    let createdAt : String
    let files : [String]
    let user : User
    
    var id : String { return dmID }
}

extension DMChat {
    var createdAtToString : String {
        return createdAt.toDateRaw()!.toString(dateFormat: "yy.MM.dd")
    }
  
    var createdAtDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: createdAt)
    }
    
//    var createdAtDate: Date? {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        
//        // Step 1: ISO 8601 문자열을 Date 객체로 변환
//        guard let date = formatter.date(from: createdAt) else {
//            return nil
//        }
//        
//        // Step 2: Calendar와 DateComponents를 사용하여 밀리초 부분을 0으로 설정
//        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
//        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
//        components.nanosecond = 0 // 밀리초를 0으로 설정
//        
//        return calendar.date(from: components)
//    }
}

typealias DMChatList = [DMChat]
