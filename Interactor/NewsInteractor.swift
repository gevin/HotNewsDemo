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
    
    let apiClient: APIClient
    
    let realm: Realm
    
    init( apiClient: APIClient, realm: Realm) {
        self.apiClient = apiClient
        self.realm = realm
    }
    
    private func getConfig() -> NewsInteractorConfig {
        let result = self.realm.objects(NewsInteractorConfig.self)
        if result.count == 0 {
            let model = NewsInteractorConfig()
            model.currentPage = 0
            try! self.realm.write {
                self.realm.add(model)
            }
            return model
        }
        return result[0]
    }
    
    func getCurrentPage() -> Int {
        let config = self.getConfig()
        return config.currentPage
    }
    
    func getArticleModel( newsId: String ) -> ArticleModel? {
        let model = self.realm.object(ofType: ArticleModel.self, forPrimaryKey: newsId)
        
        return model
    }
    
    func updateArticleContent( model: ArticleModel, newContent: String  ) {
        try! self.realm.write {
            model.content = newContent
        }
    }
    
    func fetchNextNewsHeadlines() -> Observable<[ArticleModel] > {
        
        let config = self.getConfig()
        return self.apiClient.fetchHeadlines(page: config.currentPage + 1)
            .debug()
            .map([ArticleModel].self, atKeyPath: "articles")
            .do(onNext: {[weak self] (models:[ArticleModel]) in
                guard let strongSelf = self else { return }
                
                DispatchQueue.main.async {
                    do {
                        if models.count > 0 {
                            try strongSelf.realm.write {
                                config.currentPage += 1
                                strongSelf.realm.add(models)
                            }
                        } else {
                            print("no more data.")
                        }
                    } catch {
                        print(error)
                    }
                }
            })
    }
    
    func reloadNewsHeadlines() -> Observable<[ArticleModel] > {
        let config = self.getConfig()
        try! self.realm.write {
            config.currentPage = 1
        }
        
        return self.apiClient.fetchHeadlines(page: config.currentPage)
            .debug()
            .map([ArticleModel].self, atKeyPath: "articles")
            .do(onNext: {[weak self] (models:[ArticleModel]) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    do {
                        let result = strongSelf.realm.objects(ArticleModel.self)
                        try strongSelf.realm.write {
                            strongSelf.realm.delete(result)
                            strongSelf.realm.add(models)
                        }
                    } catch {
                        print(error)
                    }
                }
            })
    }
    
    func observeArticles() -> Observable<(AnyRealmCollection<ArticleModel>, RealmChangeset?)> {
        let result = self.realm.objects(ArticleModel.self)
        return Observable.changeset(from: result)
    }
}
