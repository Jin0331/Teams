# Teams

## 🔆 **적용 기술**

* ***프레임워크***

  ​	SwiftUI

* ***아키텍쳐***

  ​	TCA

* ***오픈 소스***

    TCACoordinator
  
    Realm / Alamofire /	Kingfisher
  
    PopupView

* ***버전 관리***

  ​	Git / Github

  <br>

## 🔎 **적용 기술 소개**

***TCA***

***TCACoordinator***

***Realm***

***Alamofire***

***PopupView***

<br>

## 트러블슈팅

### 1. Coordinator에 속한 View 간 Action 전달

* **문제 상황**

    > - 아래와 같은 구조로, SideMenuView와 EditView는 SideMenuCoordinator에 포함된 하위 View이며, SideMenuView에서 수정 Button을 클릭시, EditView가 Present되는 형태임.
    > - 또한, TCA는 단방향 아키텍처를 지향하며, TCACoordinator 또한 단방향 화면 전환을 목표로 View 간 양방향 소통이 아닌, Coordinator를 통한 단방향 화면전환을 지원함. 
    > - 이때, 각 View는 서로 독립적이므로 특정 View에서 발생한 Event를 전달받아 View를 Update 해야하는 문제가 발생.

    <p align="center">
      <img src="https://github.com/Jin0331/Teams/assets/42958809/03bca249-7e30-45cf-800b-001335699d91" width="45%" height="45%"/>
    </p>

* **해결 방법**

    1. 각 View는 무한 증식되지 않으므로 `IdentifiedArrayOf<Route<SideMenuScreen.State>>`와 같이, 각 View의 State를 관리하기 위하여 `IdentifiedArrayOf`를 사용하므로써 포함된 View에 대해 Identity 지정

    2. Ientity를 지정하기 위해, `Identifiable` Protocol를 채택

        ```swift
        @Reducer(state: .equatable)
        enum SideMenuScreen {
            case sidemenu(SideMenuFeature)
            case workspaceAdd(WorkspaceAddFeature)
            case workspaceEdit(WorkspaceEditFeature)
        }
        extension SideMenuScreen.State: Identifiable {
        var id: ID {
            switch self {
            case .sidemenu:
                    .sidemenu
            case .workspaceAdd:
                    .workspaceAdd
            case .workspaceEdit:
                    .workspaceEdit
            }
        }

        enum ID: Identifiable {
            case sidemenu
            case workspaceAdd
            case workspaceEdit

            var id: ID { self }
            }
        }
        ```

    3. 또한, 각 View의 Event를 관리하기 위해, dentifiedRouterActionOf<SideMenuScreen>` 선언

    4. Coordinaotr의 Reducer에서 View 간 이벤트 전달할 수 있도록 구현
        ```swift
        var body : some ReducerOf<Self> {
            Reduce<State, Action> { state, action in
                switch action {
                    
                case .router(.routeAction(_, action: .sidemenu(.createWorkspaceTapped))):
                    state.routes.presentSheet(.workspaceAdd(.init()))
                    
                case let .router(.routeAction(_, action: .sidemenu(.workspaceEdit(workspace)))):
                    state.routes.presentSheet(.workspaceEdit(.init(workspaceID: workspace.id, workspaceImage: workspace.profileImageToUrl, workspaceName: workspace.name, workspaceDescription: workspace.description)))
                    
                case .router(.routeAction(_, action: .workspaceAdd(.dismiss))), .router(.routeAction(_, action: .workspaceEdit(.dismiss))):
                    state.routes.dismiss()
                
                case .router(.routeAction(_, action: .workspaceEdit(.editWorkspaceComplete))):
                    return .send(.router(.routeAction(id: .sidemenu, action: .sidemenu(.onAppear))))
                    
                default:
                    break
                }
                return .none
            }
        }
            .forEachRoute(\.routes, action: \.router)
        ```

