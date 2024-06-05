//
//  TargetType.swift
//  Teams
//
//  Created by JinwooLee on 6/5/24.
//

import Foundation
//
//protocol TargetType {
//    
//    var baseURL : URL { get }
//    var method : HTTPMethod { get }
//    var path : String { get }
//    var header : [String:String] { get }
//    var parameter : [String:Any]? { get }
//
//    var body : Data? { get }
//}
//
//extension TargetType {
//    
//    func asURLRequest() throws -> URLRequest {
//        let url = URL(string : baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding!)
//        
//        var request = URLRequest.init(url: url!)
//        
//        request.headers = HTTPHeaders(header)
//        request.httpMethod = method.rawValue
//        request.httpBody = body
//
//        return try URLEncoding.default.encode(request, with: parameter)
//    }
//}
