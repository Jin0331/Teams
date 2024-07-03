//
//  AuthManager.swift
//  Teams
//
//  Created by JinwooLee on 6/10/24.
//

import Alamofire
import Kingfisher
import Foundation

//MARK: - Access Token 갱신을 위한 Alamorefire RequestInterceptor protocol
final class AuthManager : RequestInterceptor {
    
    let retryLimit = 1
    
 
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        // Token이 없는 상황, 즉 로그인을 새롭게 시도하는 상황
        guard let accessToken = UserDefaultManager.shared.accessToken, let _ = UserDefaultManager.shared.refreshToken else {
            completion(.success(urlRequest))
            print("adpat Error 🥲🥲🥲🥲🥲🥲🥲🥲")
            return
        }
        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let response = request.task?.response as? HTTPURLResponse
        
        
        if let statusCode = response?.statusCode, statusCode == 400, request.retryCount < retryLimit {
            guard let accessToken = UserDefaultManager.shared.accessToken, let refreshToken = UserDefaultManager.shared.refreshToken else {
                return
            }
            
            do {
                let urlRequest = try UserRouter.refresh(query: RefreshRequestDTO(accessToken: accessToken, refreshToken: refreshToken))
                    .asURLRequest()
                
                // refresh
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: RefreshResponseDTO.self) { response in
                        switch response.result {
                        case .success(let refreshResponse): // Token이 Refresh 성공했을 때
                            print("Access Token Refresh Success ✅")
                            UserDefaultManager.shared.accessToken = refreshResponse.accessToken
                            completion(.retryWithDelay(0.5))
                        case .failure(let error):
                            print("Token Refresh Fail : \(error)")
                            UserDefaultManager.shared.accessToken = nil
                            UserDefaultManager.shared.refreshToken = nil
                            UserDefaultManager.shared.isLogined = false
                            
                            //TODO: - Notification Center를 이용해서 AppCoordinator
                            NotificationCenter.default.post(name: .resetLogin, object: nil)
                            
                            completion(.doNotRetry)
                        }
                    }
            } catch {
                
                print("알수없는 에러")
                
            }
        } else {
            completion(.doNotRetry)
        }
    }
}

extension AuthManager {
    static func kingfisherAuth() -> AnyModifier {
        guard let accessToken = UserDefaultManager.shared.accessToken else { return AnyModifier { $0 } }
        
        let modifier = AnyModifier { request in
            var req = request
            req.addValue(APIKey.secretKey.rawValue, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)
            req.addValue(accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
            return req
        }
        
        return modifier
    }
}
