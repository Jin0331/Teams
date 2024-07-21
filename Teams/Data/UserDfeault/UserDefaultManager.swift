//
//  UserDefaultManager.swift
//  Teams
//
//  Created by JinwooLee on 6/10/24.
//

import Foundation

enum UserInfo : String {
    case user_id, email, nick, deviceToken
    case userLogin, accessToken, refreshToken
}

//MARK: - Token 관리를 위한 UserDefaultManager
@propertyWrapper
struct UserStatus {
    private let key: String
 
    init(key: String) {
        self.key = key
    }
    
    var wrappedValue: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

@propertyWrapper
struct UserLogin {
    private let key: String
 
    init(key: String) {
        self.key = key
    }
    
    var wrappedValue: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
 
final class UserDefaultManager {
    
    static let shared = UserDefaultManager()
    private let userDefaults = UserDefaults.standard
    
    private init () { }
    
    // PropertyWrapper 적용
    @UserStatus(key: "accessToken") var accessToken : String?
    @UserStatus(key: "refreshToken") var refreshToken : String?
    @UserStatus(key: "deviceToken") var deviceToken : String?
    @UserStatus(key: "errorCode") var errorCode : String?
    
    @UserStatus(key: "user_id") var userId : String?
    @UserStatus(key: "email") var email : String?
    @UserStatus(key: "nick") var nick : String?
    @UserStatus(key: "profile") var profile : String?
    @UserStatus(key: "provider") var provider : String?
    @UserLogin(key: "userLogin") var isLogined : Bool
    
    
    func removeData(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clearAllData() {
        if let bundleID = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleID)
        }
    }
    
    func saveAllData(login : Join) {
        userId = login.userID
        email = login.email
        nick = login.nickname
        profile = login.profileImage
        provider = login.provider
        accessToken = login.token.accessToken
        refreshToken = login.token.refreshToken
        isLogined = true
    }
    
    func saveWorkspace(_ workspace: Workspace) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(workspace)
            userDefaults.set(data, forKey: "workspace")
        } catch {
            print("Failed to encode Workspace: \(error)")
        }
    }
    
    // Workspace 불러오기
    func getWorkspace() -> Workspace? {
        guard let data = userDefaults.data(forKey: "workspace") else { return nil }
        do {
            let decoder = JSONDecoder()
            let workspace = try decoder.decode(Workspace.self, from: data)
            return workspace
        } catch {
            print("Failed to decode Workspace: \(error)")
            return nil
        }
    }
}
