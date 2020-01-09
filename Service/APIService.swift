
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
import SDWebImage

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

protocol APIServiceType {
    func fetchHeadlines(page: Int) -> Observable<[ArticleModel]>
    func downloadImage(url: URL) -> Observable<ImageState>
}

class APIService: APIServiceType {
    
    public static var shared: APIService! 
    
    var providerHolder:[MoyaProvider<NewsAPI>] = []
    var provider = MoyaProvider<NewsAPI>()
    private var _token = "aadfc8775efa4815b8480bb830f583c9"
    var queue = DispatchQueue.global(qos: .background)
    
    init() {
        let authPlugin = AccessTokenPlugin(tokenClosure: self._token)
        self.provider = MoyaProvider<NewsAPI>(plugins: [authPlugin])
        self.provider.manager.session.configuration.timeoutIntervalForRequest = 20
    }
    
    func fetchHeadlines(page: Int) -> Observable<[ArticleModel]> {
        let apiRequest = provider.rx.request(.topHeadlines(page: page, pageSize: 10, country: "us"), callbackQueue: queue)
            .asObservable()
            .map([ArticleModel].self, atKeyPath: "articles")
        
        return apiRequest
    }
    
    func downloadImage(url: URL) -> Observable<ImageState> {
        
        let downloadImageTask = Observable<ImageState>.create({ (observer) -> Disposable in
            observer.onNext(ImageState.loading)  
            //SDWebImageDownloader.shared.setValue("", forHTTPHeaderField: "ETag")
            
            SDWebImageDownloader.shared.downloadImage(with: url, completed: {[weak self] (imageOrNil:UIImage?, dataOrNil:Data?, errorOrNil:Error?, finish:Bool)  in    
                if let error = errorOrNil {
                    observer.onNext(ImageState.error(error))
                    observer.onCompleted()
                    return
                }
                observer.onNext(ImageState.completed(imageOrNil))
                observer.onCompleted()
            })
            
            return Disposables.create()
        })
        return downloadImageTask
    }

}
