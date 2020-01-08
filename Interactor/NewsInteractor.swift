//
//  NewsInteractor.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/24.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya
import Alamofire
import Realm
import RealmSwift
import RxRealm

protocol NewsInteractorType : InteractorType {
    func getArticleModel( newsId: String ) -> ArticleModel?
    func updateArticleContent( model: ArticleModel, newContent: String )
    func getCurrentPage() -> Int
    func fetchNextNewsHeadlines() -> Observable<[ArticleModel]>
    func reloadNewsHeadlines() -> Observable<[ArticleModel]>
    func observeArticles() -> Observable<(AnyRealmCollection<ArticleModel>, RealmChangeset?)>
}

class NewsInteractor: NewsInteractorType {
    
    let apiService: APIService
    
    let realmService: RealmService
    
    var disposeBag = DisposeBag()
    
    init( apiService: APIService, realmService: RealmService) {
        self.apiService = apiService
        self.realmService = realmService
    }
    
    ///
    private func getConfig() -> NewsInteractorConfig {
        let realm = self.realmService.getRealm()
        let result = realm.objects(NewsInteractorConfig.self)
        if result.count == 0 {
            let model = NewsInteractorConfig()
            model.currentPage = 0
            try! realm.write {
                realm.add(model)
            }
            return model
        }
        return result[0]
    }
    
    /// get the number of pages loaded
    func getCurrentPage() -> Int {
        let config = self.getConfig()
        return config.currentPage
    }
    
    /// get a local ArticleModel by newsId
    func getArticleModel( newsId: String ) -> ArticleModel? {
        let realm = self.realmService.getRealm()
        let model = realm.object(ofType: ArticleModel.self, forPrimaryKey: newsId)
        
        return model
    }
    
    /// change Article Model property value, the purpose is to test realm notification.
    func updateArticleContent( model: ArticleModel, newContent: String  ) {
        let realm = self.realmService.getRealm()
        try! realm.write {
            model.content = newContent
        }
    }
    
    /// load next page
    func fetchNextNewsHeadlines() -> Observable<[ArticleModel] > {
        let config = self.getConfig()
        return self.apiService.fetchHeadlines(page: config.currentPage + 1)
            .retryPowInterval(maxRetry: 3, multiple: 2.0) // 第一次隔 2秒，第二次隔 4 秒，第三次隔 8秒
            .debug()
            .map([ArticleModel].self, atKeyPath: "articles")
            .realmWrite({ (realm:Realm, models:[ArticleModel]) in
                if models.count > 0 {
                    realm.add(models)
                } else {
                    print("no more data")
                }
            })
    }
    
    /// clear all local ArticleModel data, and refetch page 1 data from server
    func reloadNewsHeadlines() -> Observable<[ArticleModel] > {

        let realm = self.realmService.getRealm()
        let config = self.getConfig()
        try! realm.write {
            config.currentPage = 1
        }
                
        return self.apiService.fetchHeadlines(page: config.currentPage)
            .retryPowInterval(maxRetry: 3, multiple: 2.0) // 第一次隔 2秒，第二次隔 4 秒，第三次隔 8秒
            .debug()
            .map([ArticleModel].self, atKeyPath: "articles")
            .realmWrite({ (realm:Realm, models:[ArticleModel]) in
                let result = realm.objects(ArticleModel.self)
                realm.delete(result)
                if models.count > 0 {
                    realm.add(models)
                } else {
                    print("no more data")
                }
            })
    }
    
    /// subscribe ArticleModel changes event
    func observeArticles() -> Observable<(AnyRealmCollection<ArticleModel>, RealmChangeset?)> {
        let result = self.realmService.getRealm().objects(ArticleModel.self)
        return Observable.changeset(from: result)
    }
}
