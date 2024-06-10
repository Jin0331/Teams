//
//  NetworkManager.swift
//  Teams
//
//  Created by JinwooLee on 6/10/24.
//

import Foundation
import ComposableArchitecture
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    
    init() { }
    
    private func requestAPI<T:Decodable>(router : URLRequestConvertible, of type : T.Type) async throws -> T {
        
        let urlRequest = try router.asURLRequest()
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(urlRequest)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: type, emptyResponseCodes: [200]) { response in
                    switch response.result {
                    case let .success(response):
                        continuation.resume(returning: response)
                    case let .failure(error):
                        
                        if let errorData = response.data {
                            do {
                                let networkError = try JSONDecoder().decode(ErrorResponseDTO.self, from: errorData)
                                let apiError = APIError(error: networkError)
                                continuation.resume(throwing: apiError)

                            } catch {
                                continuation.resume(throwing: APIError.decodingError)
                            }
                        } else {
                            continuation.resume(throwing: error)
                        }
                    }
                }
        }
        
    }
    
    func emailValidation(query : EmailVaidationRequestDTO) async -> Result<EmailVaidationResponseDTO, APIError> {
        do {
            let response = try await requestAPI(router: UserRouter.emailValidation(query: query), of: EmailVaidationResponseDTO.self)
            return .success(response)
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                print(error)
                return .failure(APIError.unknown)
            }
        }
    }
    
}
