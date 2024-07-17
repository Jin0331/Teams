//
//  DMScreen.swift
//  Teams
//
//  Created by JinwooLee on 7/17/24.
//

import ComposableArchitecture
import Foundation

@Reducer(state: .equatable)
enum DMScreen {
    case dmList(DMListFeature)
}
