//
//  ValidTest.swift
//  Teams
//
//  Created by JinwooLee on 6/20/24.
//

import Foundation
import ComposableArchitecture

final class ValidTest {
    static let shared = ValidTest()
    
    init() { }
    
    func validEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidNickname(_ nickname: String) -> Bool {
        let minCharacters = 1
        let maxCharacters = 30
        
        return nickname.count >= minCharacters && nickname.count <= maxCharacters
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^01\\d{1}-\\d{3,4}-\\d{4}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    func formatPhoneNumber(_ number: String) -> String {
        var result = ""
        let mask = number.count < 11 ? "XXX-XXX-XXXX" : "XXX-XXXX-XXXX"
        var index = number.startIndex
        for change in mask where index < number.endIndex {
            if change == "X" {
                result.append(number[index])
                index = number.index(after: index)
            } else {
                result.append(change)
            }
        }
        return result
    }
    
    func isValidPassword(_ password: String) -> Bool {
        // 최소 8자 이상, 대소문자, 숫자, 특수문자를 포함하는 정규표현식
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        return passwordPredicate.evaluate(with: password)
    }
    
    func isPasswordMatch(_ password: String, _ passwordRepeat: String) -> Bool {
        return password == passwordRepeat
    }
}

private enum ValidTestKey: DependencyKey {
    static var liveValue: ValidTest = ValidTest()
}

extension DependencyValues {
    var validTest: ValidTest {
        get { self[ValidTestKey.self] }
        set { self[ValidTestKey.self] = newValue }
    }
}

