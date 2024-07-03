//
//  WorkspaceEditFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/2/24.
//

import ComposableArchitecture
import Foundation
import Alamofire
import Kingfisher

@Reducer
struct WorkspaceEditFeature {
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceID : String = ""
        var workspaceImage : URL?
        var workspaceName : String = ""
        var workspaceNameValid : Bool = false
        var workspaceImageValid : Bool = false
        var workspaceDescription : String = ""
        var createButton : Bool = false
        var toastPresent : ToastMessage?
        var selectedImageData: Data?
        
        enum ToastMessage : String, Hashable, CaseIterable {
            case name = "워크스페이스 이름은 1~30자로 설정해주세요"
            case image = "워크스페이스 이미지를 등록해주세요."
            case duplicate = "워크스페이스 명은 고유한 데이터로 중복될 수 없습니다."
            case none = "에러가 발생했어요. 잠시 후 다시 시도해주세요."
        }
    }
    
    enum Action : BindableAction {
        case binding(BindingAction<State>)
        case onApear
        case pickedImage(Data?)
        case createButtonActive
        case createButtonTapped
        case createWorkspaceResponse(Result<Workspace, APIError>)
        case dismiss
        case createWorkspaceComplete
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var validTest
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            
            case .onApear:
                return .run { [imageURL = state.workspaceImage] send in
                    await send(.pickedImage(loadImage(from: imageURL)))
                }
                
            case .binding(\.workspaceName):
                return .send(.createButtonActive)

            case let .pickedImage(image):
                state.selectedImageData = image
                state.workspaceImageValid = true
                return .none
                
            case .createButtonActive:
                if !state.workspaceName.isEmpty {
                    state.createButton = true
                } else {
                    state.createButton = false
                }
                return .none
            
            case .createButtonTapped:
                state.workspaceNameValid = validTest.isValidNickname(state.workspaceName)
                
                if let field = [state.workspaceNameValid, state.workspaceImageValid].firstIndex(of: false) {
                    state.toastPresent = State.ToastMessage.allCases[field]
                    return .none
                }
                
                guard let imageData = state.selectedImageData else { return .none}
                
                let createWorkspaceRequest = WorkspaceCreateRequestDTO(name: state.workspaceName,
                                                                       description: state.workspaceDescription,
                                                                       image: imageData)
                
                return .run { [workspaceID = state.workspaceID] send in
                    await send(.createWorkspaceResponse(
                        networkManager.editWorkspace(request: WorkspaceIDDTO(workspace_id: workspaceID), query: createWorkspaceRequest)
                    ))
                }
            case let .createWorkspaceResponse(.success(response)):
                
                dump(response)
                
                return .concatenate([.send(.createWorkspaceComplete), .send(.dismiss)])
                
            case let .createWorkspaceResponse(.failure(error)):
                
                dump(error)
                
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                
                if case .E12 = errorType {
                    state.toastPresent = State.ToastMessage.duplicate
                } else {
                    state.toastPresent = State.ToastMessage.none
                }
                
                return .none
            default :
                return .none
            }
        }
    }
    
    private func loadImage(from url : URL?) async -> Data? {
        
        guard let url = url else { return nil }
        
        return await withCheckedContinuation { continuation in
            
            KingfisherManager.shared.retrieveImage(with: url, options: [.requestModifier(AuthManager.kingfisherAuth())] ) { result in
                switch result {
                case let .success(response):
                    
                    let imageData = response.image.jpegData(compressionQuality: 1)
                    
                    DispatchQueue.main.async {
                        continuation.resume(returning: imageData)
                    }
                    
                case .failure(_):
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

