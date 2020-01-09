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

protocol NewsInteractorType {
    func getArticleModel( newsId: String ) -> ArticleModel?
    func updateArticleContent( model: ArticleModel, newContent: String )
    func loadedPages() -> Int
    func fetchNextNewsHeadlines() -> Observable<[ArticleModel]>
    func reloadNewsHeadlines() -> Observable<[ArticleModel]>
    func observeArticles() -> Observable<RealmCollectionChange<Results<ArticleModel>>>
    func observeArticle(_ object: ArticleModel) -> Observable<ObjectChange>
}

class NewsInteractor: NewsInteractorType {
    
    let apiService: APIServiceType
    
    let realmService: RealmServiceType
    
    var disposeBag = DisposeBag()
    
    init( apiService: APIServiceType, realmService: RealmServiceType) {
        self.apiService = apiService
        self.realmService = realmService
    }
    
    ///
    private func getConfig() -> NewsInteractorConfig {
        let realm = self.realmService.getRealm()
        let result = realm.objects(NewsInteractorConfig.self)
        if result.count == 0 {
            let model = NewsInteractorConfig()
            model.loadedPage = 0
            try! realm.write {
                realm.add(model)
            }
            return model
        }
        return result[0]
    }
    
    func setPage(_ page:Int) {
        guard page > 0 else { return }
        let config = self.getConfig()
        let realm = self.realmService.getRealm()
        try! realm.write {
            config.loadedPage = page
        }
    } 
    
    /// get the number of pages loaded
    func loadedPages() -> Int {
        let config = self.getConfig()
        return config.loadedPage
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
        return self.apiService.fetchHeadlines(page: config.loadedPage + 1)
            .debug()
            .retryPowInterval(maxRetry: 3, multiple: 2.0) // 第一次隔 2秒，第二次隔 4 秒，第三次隔 8秒
            .do(onNext: {[weak self] (models:[ArticleModel]) in
                guard let strongSelf = self else {return}
                let realm = strongSelf.realmService.getRealm()
                let config = realm.objects(NewsInteractorConfig.self).first!
                try! realm.write {
                    config.loadedPage += 1
                    realm.add(models,update: .all )
                }
            })
    }
    
    /// clear all local ArticleModel data, and refetch page 1 data from server
    func reloadNewsHeadlines() -> Observable<[ArticleModel] > {
        
        let config = self.getConfig()
        let realm = self.realmService.getRealm()
        try! realm.write {
            config.loadedPage = 0
        }
                
        return self.apiService.fetchHeadlines(page: config.loadedPage + 1)
            .debug()
            .retryPowInterval(maxRetry: 3, multiple: 2.0) // 第一次隔 2秒，第二次隔 4 秒，第三次隔 8秒
            .do(onNext: {[weak self] (models:[ArticleModel]) in
                guard let strongSelf = self else {return}
                let realm = strongSelf.realmService.getRealm()
                let result = realm.objects(ArticleModel.self)
                let config = realm.objects(NewsInteractorConfig.self).first!
                try! realm.write {
                    config.loadedPage = 1
                    realm.delete(result)
                    realm.add(models)
                }
            })
    }
    
    /// subscribe ArticleModel changes event
    func observeArticles() -> Observable<RealmCollectionChange<Results<ArticleModel>>> {
        return self.realmService.observe(ArticleModel.self)
    }
    
    /// observe single ArticleModel object 
    func observeArticle(_ object: ArticleModel) -> Observable<ObjectChange> {
        return self.realmService.observeObject(object)
    }
}
