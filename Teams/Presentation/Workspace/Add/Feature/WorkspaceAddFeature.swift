//
//  WorkspaceAddFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/20/24.
//

import ComposableArchitecture
import Foundation
import Alamofire

@Reducer
struct WorkspaceAddFeature {
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
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
        }
    }
    
    enum Action : BindableAction {
        case binding(BindingAction<State>)
        case pickedImage(Data?)
        case createButtonActive
        case createButtonTapped
        case dismiss
    }
    
    @Dependency(\.validTest) var validTest
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
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
                
                return .none
                
            default :
                return .none
            }
        }
    }
}
