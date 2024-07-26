//
//  MainCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/15/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct MainCoordinatorView : View {
    @State var store : StoreOf<MainCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.isLogined {
                    if store.isSignUp { // 회원가입시
                        HomeInitialCoordinatorView(store: store.scope(state: \.homeInitial, action: \.homeInitial))
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else {
                        WorkspaceCoordinatorView(store: store.scope(state: \.workspace, action: \.workspace))
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                } else {
                    OnboardingCoordinatorView(store: store.scope(state: \.onboarding, action: \.onboarding))
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .onAppear {
                store.send(.onApper)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetLogin)) { notification in
            store.send(.refreshTokenExposed)
        }
    }
}

@Reducer
struct MainCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(onboarding: .initialState, homeInitial: .initialState(), workspace: .initialState, isLogined: UserDefaultManager.shared.isLogined, isSignUp: false)
        var onboarding : OnboardingCoordinator.State
        var homeInitial : HomeInitialCoordinator.State
        var workspace : WorkspaceCoordinator.State
        var workspaceList : WorkspaceList?
        var isLogined : Bool
        var isSignUp : Bool
    }
    
    enum Action {
        case onApper
        case onboarding(OnboardingCoordinator.Action)
        case homeInitial(HomeInitialCoordinator.Action)
        case workspace(WorkspaceCoordinator.Action)
        case workspaceTransition(Workspace)
        case refreshTokenExposed
        case autoLogin(Result<[Workspace], APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var utilitiesFunction
    @Dependency(\.realmRepository) var realmRepository
    
    var body : some ReducerOf<Self> {
        
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingCoordinator()
        }
        Scope(state: \.homeInitial, action: \.homeInitial) {
            HomeInitialCoordinator()
        }
        Scope(state: \.workspace, action: \.workspace) {
            WorkspaceCoordinator()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
                
            //MARK: - 자동로그인에서 사용되는 부분
            case .onApper:
                realmRepository.realmLocation()
                if UserDefaultManager.shared.isLogined {
                    return .run { send in
                        await send(.autoLogin(
                            networkManager.getWorkspaceList()
                        ))}
                } else {
                    return .none
                }
                
            //TODO: - 초기에 initalState로 초기화되었다가, 비동기 action으로 state가 초기화되면서 ,땅->땅 으로 뷰가 전환됨. Progress View 필요할듯
            //MARK: - Workspace가 지정되는 부분
            case let .autoLogin(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType)
                
                
            case let .onboarding(.router(.routeAction(_, action: .emailLogin(.loginComplete(workspace))))),
                let .onboarding(.router(.routeAction(_, action: .auth(.loginComplete(workspace))))),
                let .autoLogin(.success(workspace)):
                
                state.workspaceList = workspace
                state.workspace = initializeWorkspace(with: workspace)
                
                state.isLogined = true
                state.isSignUp = false
                
            case let .workspace(.workspaceChangeComplete(workspace)):
                
                state.workspaceList = workspace
                state.workspace = initializeWorkspace(with: workspace)
                
                state.isLogined = true
                state.isSignUp = false
                
                return .send(.workspace(.tab(.home(.router(.routeAction(id: .home, action: .home(.onAppear)))))))
                
                //MARK: - Workspace Transition
            case let .workspace(.sideMenu(.router(.routeAction(_, action: .sidemenu(.workspaceTransition(selectedWorkspace)))))):
                return .run { send in
                    await send(.workspace(.tab(.home(.router(.routeAction(id: .home, action: .home(.timerOff)))))))
                    await send(.workspace(.closeSideMenu))
                    await send(.workspaceTransition(selectedWorkspace))
                }
                
            case let .workspaceTransition(selectedWorkspace):
                guard let workspaceList = state.workspaceList else { return .none }
                
                UserDefaultManager.shared.saveWorkspace(selectedWorkspace)
                state.workspace = initializeWorkspace(with: workspaceList)
                
                return .send(.workspace(.tab(.home(.router(.routeAction(id: .home, action: .home(.onAppear)))))))
                
            case let .onboarding(.router(.routeAction(_, action: .signUp(.signUpComplete(nickname))))):
                state.isLogined = true
                state.isSignUp = true
                state.homeInitial = .initialState(nickname: nickname)
                
                
            case .homeInitial(.router(.routeAction(_, action: .initial(.dismiss)))):
                state.workspace = initializeWorkspace(with: [])
                
                state.isLogined = true
                state.isSignUp = false
                
            case .refreshTokenExposed:
                state.workspace = .initialState
                state.onboarding = .initialState
                state.homeInitial = .initialState()
                
                state.isLogined = false
                state.isSignUp = false
                UserDefaultManager.shared.clearAllData()
                realmRepository.deleteALL()
                
            case .workspace(.tab(.home(.router(.routeAction(_, action: .profile(.router(.routeAction(_, action: .profile(.popupComplete(.logout)))))))))),
                    .workspace(.tab(.dm(.router(.routeAction(_, action: .profile(.router(.routeAction(_, action: .profile(.popupComplete(.logout)))))))))),
                    .workspace(.homeEmpty(.router(.routeAction(_, action: .profile(.router(.routeAction(_, action: .profile(.popupComplete(.logout))))))))),
                    .workspace(.tab(.search(.router(.routeAction(_, action: .profile(.router(.routeAction(_, action: .profile(.popupComplete(.logout)))))))))):
                state.workspace = .initialState
                state.onboarding = .initialState
                state.homeInitial = .initialState()
                
                state.isLogined = false
                state.isSignUp = false
                UserDefaultManager.shared.clearAllData()
                realmRepository.deleteALL()
                
            default:
                break
            }
            return .none
        }
    }
}

extension MainCoordinator {
    private func initializeWorkspace(with workspace: [Workspace]) -> WorkspaceCoordinator.State {
        if let selectedWorkspace = UserDefaultManager.shared.getWorkspace() {
            return WorkspaceCoordinator.State(tab: .init(home: .initialState(workspaceCurrent: selectedWorkspace),
                                                         dm: .initialState(currentWorkspace: selectedWorkspace),
                                                         search: .initialState(currentWorkspace: selectedWorkspace),
                                                         profile: .initialState(tabViewMode : true),
                                                         selectedTab: .home,
                                                         sideMenu: .initialState()),
                                              homeEmpty: .initialState,
                                              sideMenu: .initialState(),
                                              workspaceCurrent: selectedWorkspace,
                                              showingView: workspace.count > 0 ? .home : .empty)
            
        } else if let mostRecentWorkspace = utilitiesFunction.getMostRecentWorkspace(from: workspace) {
            UserDefaultManager.shared.saveWorkspace(mostRecentWorkspace)
            return WorkspaceCoordinator.State(tab: .init(home: .initialState(workspaceCurrent: mostRecentWorkspace),
                                                         dm: .initialState(currentWorkspace: mostRecentWorkspace),
                                                         search: .initialState(currentWorkspace: mostRecentWorkspace),
                                                         profile: .initialState(tabViewMode : true),
                                                         selectedTab: .home,
                                                         sideMenu: .initialState()),
                                              homeEmpty: .initialState,
                                              sideMenu: .initialState(),
                                              workspaceCurrent: mostRecentWorkspace,
                                              showingView: workspace.count > 0 ? .home : .empty)
            
            
        } else {
            return WorkspaceCoordinator.State(tab: .init(home: .initialState(),
                                                         dm: .initialState(),
                                                         search: .initialState(),
                                                         profile: .initialState(tabViewMode : true),
                                                         selectedTab: .home,
                                                         sideMenu: .initialState()),
                                              homeEmpty: .initialState,
                                              sideMenu: .initialState(),
                                              showingView: workspace.count > 0 ? .home : .empty)
        }
    }
}
