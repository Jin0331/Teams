//
//  HomeEmptyFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/17/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeEmptyFeature {
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var profileImage : URL?
    }
    
    enum Action {
        case onAppear
        case openSideMenu
        case closeSideMenu
        case buttonTapped(ButtonTapped)
        case networkResponse(NetworkResponse)
    }
    
    enum ButtonTapped {
        case profileOpenTapped
        case createWorkspaceTapped
    }
    
    enum NetworkResponse {
        case myProfile(Result<Profile, APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some ReducerOf<Self> {
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear :
                return .run { send in
                    await send(.networkResponse(.myProfile(
                        networkManager.getMyProfile()
                    )))
                }
                
            case let .networkResponse(.myProfile(.success(myProfile))):
                state.profileImage = myProfile.profileImageToUrl
                
                return .none
                
            case let .networkResponse(.myProfile(.failure(error))):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ channeListlResponse error")
                
                return .none
                
            default:
                return .none
            }
            
        }
    }
}
