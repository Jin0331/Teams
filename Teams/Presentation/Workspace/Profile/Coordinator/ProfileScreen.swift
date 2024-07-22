//
//  ProfileScreen.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import Foundation
import ComposableArchitecture

@Reducer(state: .equatable)
enum ProfileScreen {
    case profile(ProfileFeature)
    case profileEdit(ProfileEditFeature)
}

