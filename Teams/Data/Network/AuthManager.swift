////
////  AuthManager.swift
////  Teams
////
////  Created by JinwooLee on 6/10/24.
////
//
//import Alamofire
//import Kingfisher
//
////MARK: - Access Token 갱신을 위한 Alamorefire RequestInterceptor protocol
//final class AuthManager : RequestInterceptor {
// 
//    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
//        // Token이 없는 상황, 즉 로그인을 새롭게 시도하는 상황
//        guard let accessToken = UserDefaultManager.shared.accessToken, let _ = UserDefaultManager.shared.refreshToken else {
//            completion(.success(urlRequest))
//            
//            print("adpat Error 🥲🥲🥲🥲🥲🥲🥲🥲")
//            return
//        }
//        print("adpat ✅")
//        var urlRequest = urlRequest
//        urlRequest.headers.add(name: HTTPHeader.authorization.rawValue, value: accessToken)
//        completion(.success(urlRequest))
//    }
//    
//    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
//        
//        print("✅ retry")
//        
//        //TODO: - 401 이 발생할 가능성이 있을까??? -> 서버가 리셋 즉, 회원가입이 안 된 유저
//        let request = request.task?.response as? HTTPURLResponse
//        guard let response = request, response.statusCode == 419 else {
//            print("Forbidden or Unknown or Success: \(request?.statusCode)")
//            completion(.doNotRetryWithError(error))
//            return
//        }
//        
//        guard let accessToken = UserDefaultManager.shared.accessToken, let refreshToken = UserDefaultManager.shared.refreshToken else {
//            return
//        }
//        
//        do {
//            let urlRequest = try UserRouter.refresh(query: RefreshRequest(accessToken: accessToken, refreshToken: refreshToken))
//                .asURLRequest()
//            
//            // refresh
//            AF.request(urlRequest)
//                .validate(statusCode: 200..<300)
//                .responseDecodable(of: RefreshResponse.self) { response in
//                    switch response.result {
//                    case .success(let refreshResponse): // Token이 Refresh 성공했을 때
//                        print("Access Token Refresh Success ✅")
//                        UserDefaultManager.shared.accessToken = refreshResponse.accessToken
//                        completion(.retryWithDelay(1))
//                    case .failure(let error): // Token이 Refresh 실패했을 때,, refreshToken이 만료되었거나(418), 비정상적인 접근(401, 403)
//                        print("Token Refresh Fail : \(error)")
//                        
//                        UserDefaultManager.shared.accessToken = nil
//                        UserDefaultManager.shared.refreshToken = nil
//                        UserDefaultManager.shared.isLogined = false
//                        
//                        completion(.doNotRetry)
//                        
//                        //TODO: - Notification Center를 이용해서 AppCoordinator
//                        NotificationCenter.default.post(name: .resetLogin, object: nil)
//                    }
//                }
//        } catch { 
//            
//            print("알수없는 에러")
//            
//        } // 어떤 에러가 발생할 수 있을까....?
//        
//    }
//}
//
//extension AuthManager {
//    static func kingfisherAuth() -> AnyModifier {
//        guard let accessToken = UserDefaultManager.shared.accessToken else { return AnyModifier { $0 } }
//        
//        let modifier = AnyModifier { request in
//            var req = request
//            req.addValue(APIKey.secretKey.rawValue, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)
//            req.addValue(accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
//            return req
//        }
//        
//        return modifier
//    }
//}
