# Teams - 업무 협업툴

> 출시 기간 : 2024.05.23 - 진행중
>
> 기획/디자인/개발 1인 개발
>
> 프로젝트 환경 - iPhone 전용(iOS 16.0+), 라이트 모드 고정

---

<br>

## 🔆 **한줄소개**

***우리들의 효율적인 업무 협업을 위한 Teams***

<br>

## 🔆 **적용 기술**

* ***프레임워크***

    SwiftUI

* ***아키텍쳐***

    The Composable Architecture(TCA)

* ***오픈 소스***

    TCACoordinator

    Realm / Alamofire /	SocketIO / Kingfisher

    PopupView

* ***버전 관리***

    Git / Github

  <br>

## 🔆 **적용 기술 소개**

***TCA***

***TCACoordinator***

***Realm***

***Alamofire***

***Socket.IO***

***Kingfisher***

***PopupView***

<br>

## 🔆 트러블슈팅

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
<br>

### 2. TCA Action의 Effect에서 Complete 이후 send 추가적인 Action 이벤트 방출

* **문제 상황**

    > - 실시간 채팅 구현을 위해, Action 내부에서 Socket을 연결하고, Socket으로 부터 전달된 데이터를 다른 Action으로 보내는 과정에서 `An action was sent from a completed effect` 에러가 발생
    >
    > - Task에서 Socket 연결 직후 Effect(`.run`) 구문이 종료되어, Action(`await send(.socket(.socketRecevieHandling(decodedData.toDomain()))`) 이벤트가 지속적으로 발생되는 비정상적인 과정이 발생
    > - Effect는 종료되었지만, Socket이 정상적으로 연결되어 있으므로 값을 받아오게 되고, 후처리 로직이 문제없이 수행되지만 TCA에서 관리할 수 없는 상태가 되어 해당 에러가 발생함.

    ```swift
    case .socketReceive:
        return .run { [socket = state.socket] send in
            Task {
                state.socket.on(clientEvent: .connect) { data, ack in
                    print("socket connected", data, ack) }
            
                state.socket.on(clientEvent: .disconnect) { data, ack in
                    print("socket disconnected") }
            
                state.socket.on("channel") { dataArray, ack in
                    if let data = dataArray.first {
                        do {
                            let result = try JSONSerialization.data(withJSONObject: data)
                            let decodedData = try JSONDecoder().decode(ChannelChatResponseDTO.self, from: result)
                            await send(.socket(.socketRecevieHandling(decodedData.toDomain())))

                        } catch { }
                    }
                }
            }
        }
    ```

* **해결 방법**

    1.  Effect가 Socket 연결 이후에도 종료되지 않도록, 해당 구문을 `AsyncStream`으로 변경하여 비동기 Sequence로 적용 후 `for await`을 통해 Stream을 지속적으로 받을 수 있는 대기 상태로 변경.

    2. SocketIOManager 구성 후, 반환값을 `AsyncStream<Result<T, APIError>>`으로 설정

    ```swift
    # SocketIOManager 반환값 예시
    return AsyncStream { [weak self] continuation in
        guard let self else {
            continuation.yield(.failure(.unknown))
            self?.stopAndRemoveSocket()
            continuation.finish()
            return
        }
        print("AsyncStream Start")
        self.setupSocketHandlers(continuation: continuation, type: type, eventName: socketCase.eventName)
        socket?.connect()
        
        continuation.onTermination = { @Sendable _ in
            print("AsyncStream End")
            self.stopSocket()
        }
    }
    ```

    3. Effect가 종료되지 않게 `AsyncStream`을 지속적으로 처리 및 대기 상태를 유지하기 위해 `for await`을 통한 비동기 Stream 처리 구문 추가

    ```swift
    # Effect 내부
    case .socket(.socketConnect):
        return .run { [ channelID = state.channelCurrent.channelID ] send in
            let socketStream = await socketManager.connect(to: .channelChat(channelID: channelID), type: ChannelChatResponseDTO.self)
            for await stream in socketStream {
                switch stream {
                case let .success(response):
                    await send(.socket(.socketRecevieHandling(response.toDomain())))
                case let .failure(error):
                    let errorType = APIError.networkErrorType(error: error.errorDescription)
                    print(errorType, error)
                }
            }
        }
    ```
