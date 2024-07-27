//
//  WorkspaceCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/17/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators
import PopupView

struct WorkspaceCoordinatorView : View {
    @State var store : StoreOf<WorkspaceCoordinator>
    @State var isanimated: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment:.leading) {
                VStack {
                    //TODO: - Progress View
                    switch store.showingView {
                    case .loading:
                        VStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.2, anchor: .center)
                                .padding()
                            Spacer()
                        }
                    case .empty :
                        HomeEmptyCoordinatorView(store: store.scope(state: \.homeEmpty, action: \.homeEmpty))
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    case .home:
                        WorkspaceTabCoordinatorView(store: store.scope(state: \.tab, action: \.tab))
                    }
                }
                .zIndex(1)
                
                if store.sidemenuOpen {
                    SideMenuCoordinatorView(store: store.scope(state: \.sideMenu, action: \.sideMenu))
                        .frame(width: 317)
                        .transition(.move(edge: .leading))
                        .zIndex(3)
                    Color.brandBlack
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .zIndex(2)
                        .onTapGesture {
                            store.send(.closeSideMenu)
                        }
                }
            }
            .popup(item: $store.popupPresent) { popup in
                switch popup {
                case .workspaceRemove, .workspaceExit, .workspaceExitManager:
                    PopupButtonWorkspaceView(store: store, action: popup)
                case .ownerChange, .workspaceChange, .channelCreate:
                    ToastView(text: popup.toastMessage)
                }
            } customize: {
                if let popup = store.popupPresent, popup == .ownerChange || popup == .workspaceChange || popup == .channelCreate {
                    $0.autohideIn(3.5)
                } else {
                    
                    $0.closeOnTap(false)
                        .closeOnTapOutside(true)
                        .backgroundColor(.black.opacity(0.4))
                }
            }
            .statusBar(hidden: store.sidemenuOpen)
            .animation(.default, value: store.sidemenuOpen)
            .animation(.default, value: store.showingView)
        }
    }
    
}

@Reducer
struct WorkspaceCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(tab: .initialState ,homeEmpty: .initialState, sideMenu: .initialState(), workspaceCurrent : nil, showingView : .loading)
        var tab : WorkspaceTabCoordinator.State
        var homeEmpty : HomeEmptyCoordinator.State
        var sideMenu : SideMenuCoordinator.State
        var workspaceCurrent : Workspace?
        var showingView : viewState
        var sidemenuOpen : Bool = false
        var isAnimation : Bool = false
        var popupPresent : CustomPopup?
    }
    
    enum Action : BindableAction {
        case tab(WorkspaceTabCoordinator.Action)
        case homeEmpty(HomeEmptyCoordinator.Action)
        case sideMenu(SideMenuCoordinator.Action)
        case onAppear
        case myWorkspaceResponse(Result<[Workspace], APIError>)
        case closeSideMenu
        case dismissPopupView
        case workspaceRemoveOnPopupView(String)
        case workspaceExitOnPopupView(String)
        case workspaceRemoveResponse(Result<WorkspaceRemoveResponseDTO, APIError>)
        case workspaceExitResponse(Result<[Workspace], APIError>)
        case workspaceChangeComplete([Workspace])
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some ReducerOf<Self> {
        
        Scope(state : \.tab, action: \.tab) {
            WorkspaceTabCoordinator()
        }
        
        Scope(state : \.homeEmpty, action: \.homeEmpty) {
            HomeEmptyCoordinator()
        }
        
        Scope(state : \.sideMenu, action : \.sideMenu) {
            SideMenuCoordinator()
        }
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            
            case .onAppear :
                return .run { send in
                    await send(.myWorkspaceResponse(
                        networkManager.getWorkspaceList()
                    ))
                }
            case let .myWorkspaceResponse(.success(response)):
                return .send(.workspaceChangeComplete(response))
                
            case let .myWorkspaceResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(error, errorType)
                
                return .none
                
            case .closeSideMenu:
                state.popupPresent = nil
                state.sidemenuOpen = false
                
                
            case .homeEmpty(.router(.routeAction(_, action: .workspaceAdd(.createWorkspaceComplete)))), .sideMenu(.router(.routeAction(_, action: .workspaceAdd(.createWorkspaceComplete)))):
                print("workspace add complete 🌟🌟🌟🌟")
                UserDefaultManager.shared.removeCurrentWorkspace()
                return .concatenate([ .send(.tab(.home(.router(.routeAction(id: .home, action: .home(.timerOff)))))),
                                      .send(.closeSideMenu),
                                      .send(.onAppear)])
                
            case .homeEmpty(.router(.routeAction(_, action: .emptyView(.openSideMenu)))), .tab(.home(.router(.routeAction(_, action: .home(.openSideMenu))))):
                if let workspaceCurrent = state.workspaceCurrent {
                    state.sideMenu = .initialState(workspaceIdCurrent: workspaceCurrent.id)
                }
                state.sidemenuOpen = true
                
            case .homeEmpty(.router(.routeAction(_, action: .emptyView(.closeSideMenu)))), .tab(.home(.router(.routeAction(_, action: .home(.closeSideMenu))))):
                return .send(.closeSideMenu)
                
            case let .sideMenu(.router(.routeAction(_, action: .sidemenu(.workspaceRemove(workspaceID))))):
                state.popupPresent = .workspaceRemove(titleText: "워크스페이스 삭제", bodyText: "정말 이 워크스페이스를 삭제하시겠습니까? 삭제 시 채널/멤버/채팅 등 워크스페이스 내의 모든 정보가 삭제되며 복구할 수 없습니다.", buttonTitle: "삭제", id:workspaceID, twoButton: true)
            
            case let .sideMenu(.router(.routeAction(_, action: .sidemenu(.workspaceExit(workspaceID))))):
                state.popupPresent = .workspaceExit(titleText: "워크스페이스 나가기", bodyText: "정말 이 워크스페이스를 떠나시겠습니까?", buttonTitle: "나가기", id:workspaceID, twoButton: true)
            
            case .sideMenu(.router(.routeAction(_, action: .sidemenu(.workspaceExitManager)))):
                state.popupPresent = .workspaceExitManager(titleText: "워크스페이스 관리자 변경 불가", bodyText: "워크스페이스 멤버가 없어 관리자 변경을 할 수 없습니다.새로운 멤버를 워크스페이스에 초대해보세요. ", buttonTitle: "확인", twoButton: false)
                
            case .dismissPopupView:
                state.popupPresent = nil
                
            case let .workspaceRemoveOnPopupView(removeWorkspaceID):
                
                let query = WorkspaceIDRequestDTO(workspace_id: removeWorkspaceID, channel_id: "", room_id: "")
                
                return .run { send in
                    await send(.tab(.home(.router(.routeAction(id: .home, action: .home(.timerOff))))))
                    await send(.workspaceRemoveResponse(
                        networkManager.removeWorkspace(query: query)
                    ))
                }
                
            case let .workspaceRemoveResponse(.failure(error)) :
                
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(error, errorType)
                
                return .none
            
            case let .workspaceExitOnPopupView(exitWorkspaceID):
                let query = WorkspaceIDRequestDTO(workspace_id: exitWorkspaceID, channel_id: "", room_id: "")
                
                return .run { send in
                    await send(.workspaceExitResponse(
                        networkManager.exitWorkspace(query: query)
                    ))
                }
                
            case .workspaceExitResponse(.success(_)), .workspaceRemoveResponse(.success(_)):
                print("workspace exit or remove complete 🔆")
                UserDefaultManager.shared.removeCurrentWorkspace()
                return .concatenate([ .send(.tab(.home(.router(.routeAction(id: .home, action: .home(.timerOff)))))),
                                      .send(.closeSideMenu),
                                      .send(.onAppear)])
                
            case .sideMenu(.router(.routeAction(id: .workspaceEdit, action: .workspaceEdit(.editWorkspaceComplete)))):
                print("workspace edit complete 🔆")
                UserDefaultManager.shared.removeCurrentWorkspace()
                return .concatenate([ .send(.tab(.home(.router(.routeAction(id: .home, action: .home(.timerOff)))))),
                                      .send(.onAppear)])
                
            case let .workspaceExitResponse(.failure(error)) :
                
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(error, errorType)
                
                return .none
                
            default :
                break
            }
            return .none
        }
    }
}

extension WorkspaceCoordinator {
    
    enum viewState {
        case loading
        case empty
        case home
    }
    
    enum CustomPopup : Equatable {
        case workspaceRemove(titleText:String, bodyText:String, buttonTitle:String, id:String, twoButton:Bool)
        case workspaceExit(titleText:String, bodyText:String, buttonTitle:String, id:String, twoButton:Bool)
        case workspaceExitManager(titleText:String, bodyText:String, buttonTitle:String, twoButton:Bool)
        case ownerChange, workspaceChange, channelCreate
        
        var toastMessage : String {
            switch self {
            case .ownerChange:
                return "채널 관리자가 변경되었습니다."
            case .workspaceChange:
                return "워크스페이스가 편집되었습니다"
            case .channelCreate:
                return "채널이 생성되었습니다"
            default :
                return ""
            }
        }
    }
}
