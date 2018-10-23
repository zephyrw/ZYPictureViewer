//
//  PictureRouter.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/10/22.
//  Copyright © 2018 Zephyr. All rights reserved.
//

import Alamofire

enum PictureRouter: URLRequestConvertible {
    
    enum Constants {
        static let baseURLPath = "https://api.unsplash.com"
        //免费Key,每小时限制api最多调用50次
        static let accessKey = "Client-ID 7e0900e036cea8db23a5639f49c7c696095eb8360f0ba170a9f68f9653d69401"
    }
    
    case photos(String, Int)
    case curatedPhotos(Int)
    
    var method: HTTPMethod {
        switch self {
        case .photos:
            return .get
        case .curatedPhotos:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .photos:
            return "/photos"
        case .curatedPhotos:
            return "/photos/curated"
        }
    }
        
    var parameters: [String : Any] {
        switch self {
        case .photos(let orderBy,let page):
            return [ "per_page" : "30",
                     "page" : page,
                     "order_by" : orderBy ]
        case .curatedPhotos(let page):
            return [ "per_page" : "30",
                     "page" : page ]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try Constants.baseURLPath.asURL()
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue(Constants.accessKey, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10 * 1000)
        
        return try URLEncoding.default.encode(request, with: parameters)
    }
    
}
