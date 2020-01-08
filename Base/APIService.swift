
//
//  APIService.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/24.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya
import Alamofire

enum NewsAPI {
    case topHeadlines( page: Int, pageSize: Int, country: String ) // get https://newsapi.org/v2/top-headlines?country=us&apiKey=aadfc8775efa4815b8480bb830f583c9
    case everything(q: String )  // get https://newsapi.org/v2/everything?q=bitcoin&apiKey=aadfc8775efa4815b8480bb830f583c9
    case sources     // get https://newsapi.org/v2/sources?apiKey=aadfc8775efa4815b8480bb830f583c9
}

extension NewsAPI: Moya.TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        return URL(string: "https://newsapi.org/v2/")!
    }
    
    var path: String {
        switch self {
        case .topHeadlines:
            return "top-headlines"
        case .everything:
            return "everything"
        case .sources:
            return "sources"
        default:
            return "top-headlines"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        switch self {
        case .topHeadlines:
            return "".data(using: String.Encoding.utf8)!
        case .everything:
            return "".data(using: String.Encoding.utf8)!
        case .sources:
            return "".data(using: String.Encoding.utf8)!
        default:
            return "".data(using: String.Encoding.utf8)!
        }
    }
    
    var task: Task {
        var params:[String : Any] = [:]
        switch self {
        case .topHeadlines(let page, let pageSize, let country):
            params["country"] = country
            params["page"] = page
            params["pageSize"] = pageSize
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .everything(let q):
            params["q"] = q
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .sources:
            return .requestPlain
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }

    var authorizationType: AuthorizationType {
        return .bearer
    }
    
}

class APIService: NSObject {
    
    var providerHolder:[MoyaProvider<NewsAPI>] = []
    var provider = MoyaProvider<NewsAPI>()
    private var _token = "aadfc8775efa4815b8480bb830f583c9"
    var queue = DispatchQueue.global(qos: .background)
    
    override init() {
        super.init()
        let authPlugin = AccessTokenPlugin(tokenClosure: self._token)
        self.provider = MoyaProvider<NewsAPI>(plugins: [authPlugin])
        self.provider.manager.session.configuration.timeoutIntervalForRequest = 20
    }
    
func fetchHeadlines(page: Int) -> Observable<Response> {
    let apiRequest = provider.rx.request(.topHeadlines(page: page, pageSize: 10, country: "us"), callbackQueue: queue)
            .asObservable()
            
        return apiRequest
    }

}
