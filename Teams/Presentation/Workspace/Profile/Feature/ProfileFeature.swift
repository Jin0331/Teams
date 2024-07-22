//
//  ProfileFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ProfileFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var nickname : String = ""
        var phonenumber : String = ""
        var email : String = ""
        var coin : Int = 0
        var provider : String = ""
        var profileImage : URL?
        var selectedImageData: Data?
        var toastPresent : ToastMessage?
        var viewType : viewState = .loading
    }
    
    enum Action : BindableAction {
        case onAppear
        case goBack
        case pickedImage(Data?)
        case networkResponse(NetworkResponse)
        case buttonTapped(ButtonTapped)
        case binding(BindingAction<State>)
    }
    
    enum ButtonTapped {
        case changeProfileImage(Data?)
    }
    
    enum NetworkResponse {
        case myProfile(Result<Profile, APIError>)
        case myProfileImageChange(Result<Profile, APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var utilitiesFunction
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            
            switch action {
            
            case .onAppear :
                return .run { send in
                    await send(.networkResponse(.myProfile(
                        networkManager.getMyProfile()
                    )))
                }
                
            //MARK: - OnAppear 때 한번 실행됨
            case let .pickedImage(image):
                state.selectedImageData = image
                return .none
        
            //MARK: - Profile 이미지 수정
            case let .buttonTapped(.changeProfileImage(imageData)):
                guard let imageData else { return .none }
                return .run { send in
                    await send(.networkResponse(.myProfileImageChange(
                        networkManager.editMyProfileImage(query: ProfileImageChangeRequestDTO(image: imageData))
                    )))
                }
            
            case let .networkResponse(.myProfile(.success(myProfile))):
                state.nickname = myProfile.nickname
                state.phonenumber = myProfile.phone
                state.email = myProfile.email
                state.coin = myProfile.sesacCoin
                state.provider = myProfile.provider
                state.profileImage = myProfile.profileImageToUrl
                state.viewType = .success
                
                return .run { [imageURL = state.profileImage] send in
                    await send(.pickedImage(utilitiesFunction.loadImage(from: imageURL)))
                }
            
            case let .networkResponse(.myProfileImageChange(.success(myProfile))):
                state.profileImage = myProfile.profileImageToUrl
                state.toastPresent = ToastMessage.profileChange
            
                return .run { [imageURL = state.profileImage] send in
                    await send(.pickedImage(utilitiesFunction.loadImage(from: imageURL)))
                }
                
            case let .networkResponse(.myProfile(.failure(error))), let .networkResponse(.myProfileImageChange(.failure(error))):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(error, errorType)
                
                return .none
                
            default :
                return .none
                
            }
        }
    }
}

extension ProfileFeature {
    enum ToastMessage : String, Hashable, CaseIterable {
        case profileChange = "프로필 이미지가 성공적으로 변경되었습니다."
    }
    
    enum viewState  {
        case loading
        case success
    }
}
