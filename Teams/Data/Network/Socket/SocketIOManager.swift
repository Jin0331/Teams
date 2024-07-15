//
//  SocketIOManager.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import Foundation
import SocketIO
import ComposableArchitecture

final class SocketIOManager {
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    func startSocket() {
        print("소켓 시도 시작")
        socket?.connect()
    }
    
    func stopAndRemoveSocket() {
        stopSocket()
        removeSocket()
    }
    
    func stopSocket() {
        print("소켓 멈춥니다.")
        socket?.disconnect()
    }
    
    func removeSocket() {
        print("소켓 완전 제거")
        if let socket {
            manager?.removeSocket(socket)
        }
        socket = nil
    }
}

extension SocketIOManager {
    
    func connect<T: Decodable>(to socketCase: SocketCase, type: T.Type) -> AsyncStream<Result<T, APIError>> {
        let base = APIKey.baseURL.rawValue
        guard let url = URL(string: base) else {
            print("유효하지 않은 소켓 URL")
            return AsyncStream { continuation in
                continuation.yield(.failure(.unknown))
                continuation.finish()
            }
        }
        print("소켓 요청 URL :" + url.absoluteString)
        
        let config: SocketIOClientConfiguration = [
            .log(false), // 로그
            .compress, // 압축
            .reconnects(true),
            .reconnectWait(10),
            .reconnectAttempts(-1), // 무한 재연결
            .forceNew(true), // 새로운 것이 있을 시 예전 것 삭제
            .secure(false), // https
            .compress
        ]
        
        manager = SocketManager(socketURL: url, config: config)
        socket = manager?.socket(forNamespace: socketCase.address)
        
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
    }
    
    private func setupSocketHandlers<T: Decodable>(continuation: AsyncStream<Result<T, APIError>>.Continuation, type: T.Type, eventName: String) {
        socket?.on(clientEvent: .connect) { data, ack in
            print("connection socket")
        }
        
        socket?.on(clientEvent: .disconnect) { data, ack in
            print("stop socket")
            print("\(data) - \(ack)")
        }
        
        socket?.on(clientEvent: .error) { data, ack in
            print("error socket")
            continuation.yield(.failure(.unknown))
            self.stopAndRemoveSocket()
            continuation.finish()
        }
        
        socket?.on(eventName) { dataArray, ack in
            do {
                if let datafirst = dataArray.first {
                    let jsonData = try JSONSerialization.data(withJSONObject: datafirst, options: [])
                    let dto = try JSONDecoder().decode(T.self, from: jsonData)
                    continuation.yield(.success(dto))
                } else {
                    continuation.yield(.failure(.decodingError))
                    self.stopAndRemoveSocket()
                    continuation.finish()
                }
            } catch {
                print("소켓에 Unknown Error")
                continuation.yield(.failure(.unknown))
                self.stopAndRemoveSocket()
                continuation.finish()
            }
        }
    }
}

private enum SocketIOManagerKey: DependencyKey {
    static var liveValue: SocketIOManager = SocketIOManager()
}

extension DependencyValues {
    var socketManager: SocketIOManager {
        get { self[SocketIOManagerKey.self] }
        set { self[SocketIOManagerKey.self] = newValue }
    }
}

