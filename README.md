# 👨🏻‍💻 Teams - 업무 협업툴

![목업변환병합1](https://github.com/user-attachments/assets/91789873-ccda-4004-b81b-8c90f91fbc46)

![목업변환병합2](https://github.com/user-attachments/assets/e137558b-64e5-447e-bdf9-a6204a828a89)

> 출시 기간 : 2024.06.03 - 07.25
>
> 기획/디자인/개발 1인 개발
>
> 프로젝트 환경 - iPhone 전용(iOS 16.0+), 라이트 모드 고정

---

<br>

## 👨🏻‍💻 **한줄소개**

***우리들의 효율적인 업무 협업을 위한 Teams***

<br>

## 👨🏻‍💻 **핵심 기능**

* 멤버 관리

    * SNS(Apple, 카카오톡 등), 이메일 회원가입 및 로그인
    * 프로필 설정

* 워크스페이스

    * 주제별 워크스페이스 생성, 삭제, 편집, 관리자 양도, 멤버 초대 기능 (관리자 모드)
    * 워크스페이스의 채널별 실시간 단체 채팅 지원, 워크스페이스 멤버간 실시간 1:1 채팅 지원(메세지 당 이미지 5개 이하, 파일 첨부 기능)
    * 워크스페이스의 채널, 멤버 검색 기능


## 👨🏻‍💻 **적용 기술**

* ***프레임워크***

    SwiftUI

    The Composable Architecture(TCA)
  
    TCACoordinator

* ***오픈 소스***

    Realm / Alamofire /	SocketIO / Kingfisher

    PopupView / Chat

* ***버전 관리***

    Git / Github

  <br>

## 👨🏻‍💻 **적용 기술 소개**

***SwiftUI + TCA***

* 일관된 상태 관리, 비즈니스 로직의 분리, Dpendency Injection(DI) 등을 통하여 코드의 유지보수성과 재사용성을 높이기 위해 The Composable Architecture(TCA) 적용.

    ```swift 
    @Reducer
    struct HomeFeature {    
        @ObservableState
        struct State : Equatable {
            let id = UUID()
            ...
        }
        
        enum Action : BindableAction{
            case binding(BindingAction<State>)
            case buttonTapped(ButtonTapped)
            case networkResponse(NetworkResponse)
            ...
        }
        
        @Dependency(\.networkManager) var networkManager
        @Dependency(\.utilitiesFunction) var utils
        
        var body : some ReducerOf<Self> {
            BindingReducer()
            Reduce<State, Action> { state, action in
                switch action {
                    ...
                }
            }
        }   
    }
    ```

<br>

***TCACoordinator***

* TCA가 적용된 상태에서 View 간 효율적인 화면전환을 위해 Coordinator Pattern 적용.

    ![Teams drawio (1)](https://github.com/user-attachments/assets/dff306c1-c0bd-4f45-97e6-f015db31f147)

* Coordinator의 구성으로, TCARouter를 이용하여 해당 Coordiantor에 속한 View 구성

    ```swift
    struct CoordinatorView : View {
        let store : StoreOf<Coordinator>
        
        var body : some View {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .dmList(store):
                    ListView(store: store)
                    ...
                }
            }
        }
    }

    @Reducer
    struct Coordinator {
        @ObservableState
        struct State : Equatable {
            var routes: IdentifiedArrayOf<Route<Screen.State>>
        }
        
        enum Action {
            case router(IdentifiedRouterActionOf<Screen>)
        }
        
        var body : some ReducerOf<Self> {
            Reduce<State, Action> { state, action in
                switch action {
                case .router(.routeAction(_, action: .list(.buttonTapped(.profileOpenTapped)))):
                    state.routes.push(.profile(.initialState()))   
                case .router(.routeAction(_, action: .inviteMember(.dismiss))):
                    state.routes.dismiss()
                    ...
                }
            }
            .forEachRoute(\.routes, action: \.router)
        }
    }

    ```

<br>

***Realm***

* Workspace 별 Channel 및 DM 채팅을 위한 Repository Pattern 기반의 데이터 로직 추상화

* 아래와 같은 Database Schema 구성 (**1:N**)
  
    ![Untitled (3)](https://github.com/user-attachments/assets/eadcb91f-390d-4af9-be39-6eddc196211b)


<br>

***Alamofire***

* `URLRequestConvertible`을 활용한 `Router 패턴` 기반의 `GET/POST/DEL/PUT` 메소드를 활용한 `RESTful API Network`와의 통신 구현

* `RequestInterceptor Protocol` 채택함으로써, `JWT(Json Web Token)` 갱신 적용

<br>

***Socket.IO + Chat***

* `Socket.IO`와 `Chat` 라이브러리를 이용한 실시간 개인, 단체 채팅 구현

* `AsyncStream<Result<T, APIError>>`를 이용한 Success 또는 Failure Response Decoding 스트림 제공

<p align="center" style="display: inline-block;">
  <img src="https://github.com/user-attachments/assets/ab8b4e27-f45e-428a-91cf-76007d62668a" width="30%" height="30%"/>
  <img src="https://github.com/user-attachments/assets/3c73f1b1-564b-4160-bc69-1032a387450e" width="30%" height="30%"/>
</p>


<br>

***PopupView***

* `PopupView` 라이브러리를 이용한 두 가지 형태의 `Toast Menu 구현`

<p align="center" style="display: inline-block;">
  <img src="https://github.com/user-attachments/assets/ae7e450c-ede5-43ff-9080-0c7eaaed8dd3" width="30%" height="30%"/>
  <img src="https://github.com/user-attachments/assets/1b8dbcf1-1eb6-4eeb-b42b-5dfdbab85be2" width="30%" height="30%"/>
</p>

<br>

## 👨🏻‍💻 트러블슈팅

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

    2. Identity를 지정하기 위해, `Identifiable` Protocol를 채택

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

    3. 또한, 각 View의 Event를 관리하기 위해, `IdentifiedRouterActionOf<SideMenuScreen>` 선언

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
    > - Task에서 Socket 연결 직후 Effect(`.run`) 구문이 종료되었지만, Action(`await send(.socket(.socketRecevieHandling(decodedData.toDomain()))`) 이벤트가 지속적으로 방출되는 비정상적인 현상이 나타남
    > - Socket이 정상적으로 연결되어 있으므로 양방향 통신으로 값을 지소적으로 받아오게 되고, 데이터 처리로직이 문제없이 수행되지만 TCA 프레임워크에서 관리할 수 없는 상태가 되어 해당 에러가 발생함

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
