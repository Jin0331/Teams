//
//  UserModel.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import Foundation
import RealmSwift

final class UserModel : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id : ObjectId
    @Persisted var userID : String
    @Persisted var email : String
    @Persisted var nickname : String
    @Persisted var profileImage : String
}

extension UserModel {
    convenience init(from response : User) {
        self.init()
        userID = response.id
        email = response.email
        nickname = response.nickname
        profileImage = response.profileImage
    }
}
