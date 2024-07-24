//
//  ProfileOtherFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/25/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ProfileOtherFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var userID : String?
        var otherProfile : Profile?
    }
    
    enum Action {
        case onAppear
        case goback
        case networkResponse(NetworkResponse)
    }
    
    enum NetworkResponse {
        case otherProfileResponse(Result<Profile, APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
            
            case .onAppear:
                guard let userID = state.userID else { return .none }
                return .run { send in
                    await send(.networkResponse(.otherProfileResponse(
                        networkManager.getOtherProfile(query: userID)
                    )))
                }
            
            case let .networkResponse(.otherProfileResponse(.success(profile))):
                state.otherProfile = profile
                
                dump(profile)
                
                return .none
                
            case let .networkResponse(.otherProfileResponse(.failure(error))):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ error")
                return .none
            
                
            default :
                return .none
            }
            
        }
    }
}
