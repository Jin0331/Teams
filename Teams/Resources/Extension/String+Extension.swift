//
//  String+Extension.swift
//  Teams
//
//  Created by JinwooLee on 7/13/24.
//

import Foundation
import UIKit

extension String {
    func toURLWithHeader() -> URLRequest? {
        
        guard let token = UserDefaultManager.shared.accessToken else { return nil }
        guard let originalURL = URL(string: self) else { return nil }

        var request = URLRequest(url: originalURL)
        request.addValue(APIKey.secretKey.rawValue, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)
        request.addValue(token, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        
        return request
    }
    
    func addHeadersToURLAsQueryParameters(url: URL, headers: [String: String]) -> URL? {
        // URLComponents를 사용하여 URL 분해
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        // 기존 쿼리 매개변수 유지
        var queryItems = urlComponents?.queryItems ?? []
        
        // 헤더 정보를 쿼리 매개변수로 변환
        let headerQueryItems = headers.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        // 쿼리 매개변수에 헤더 추가
        queryItems.append(contentsOf: headerQueryItems)
        
        // URLComponents에 업데이트된 쿼리 매개변수 설정
        urlComponents?.queryItems = queryItems
        
        // 새로운 URL 반환
        return urlComponents?.url
    }
}
