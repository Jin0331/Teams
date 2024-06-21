//
//  WorkspaceCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/17/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct WorkspaceCoordinatorView : View {
    @State var store : StoreOf<WorkspaceCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.workspaceCount > 0 {
                    Text("hihi")
                } else {
                    HomeEmptyViewCoordinatorView(store: store.scope(state: \.homeEmpty, action: \.homeEmpty))
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
    
}

@Reducer
struct WorkspaceCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(homeEmpty: .initialState, workspaceCount: 0)
        var homeEmpty : HomeEmptyViewCoordinator.State
        var workspaceCount : Int
    }
    
    enum Action {
        case homeEmpty(HomeEmptyViewCoordinator.Action)
        case onAppear
        case myWorkspaceResponse(Result<[Workspace], APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some ReducerOf<Self> {
        Scope(state : \.homeEmpty, action: \.homeEmpty) {
            HomeEmptyViewCoordinator()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
                
            //TODO: - Workspace count API 호출
            case .onAppear:
                print("Workspace Coordinator 뿅 🌟🌟🌟🌟🌟🌟🌟🌟🌟")
                return .run { send in
                    await send(.myWorkspaceResponse(
                        networkManager.getWorkspaceList()
                    ))
                }
            
            case let .myWorkspaceResponse(.success(response)):
                print(response, "🌟 success")
                state.workspaceCount = response.count
                return .none
                
            case let .myWorkspaceResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                
                print(errorType)
                
                return .none
                
                
            default :
                break
            }
            return .none
        }
    }
}
