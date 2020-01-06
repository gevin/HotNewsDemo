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
    func updateArticleContent( model: ArticleModel, newContent: String  )
    func fetchNewsHeadlines() -> Observable<[ArticleModel]>
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
    
    func getArticleModel( newsId: String ) -> ArticleModel? {
        let model = self.realm.object(ofType: ArticleModel.self, forPrimaryKey: newsId)
        
        return model
    }
    
    func updateArticleContent( model: ArticleModel, newContent: String  ) {
        try! self.realm.write {
            model.content = newContent
        }
    }
    
    func fetchNewsHeadlines() -> Observable<[ArticleModel] > {
        let result = self.realm.objects(ArticleModel.self)
        if result.count > 0 {
            return Observable.of(result.toArray())
        }
        
        return self.apiClient.fetchHeadlines()
            .debug()
            .map([ArticleModel].self, atKeyPath: "articles")
            .do(onNext: {[weak self] (models:[ArticleModel]) in
                guard let strongSelf = self else { return }
                do {
                    try strongSelf.realm.write {
                        strongSelf.realm.add(models)
                    }
                } catch {
                    print(error)
                }
            })
    }
    
    func reloadNewsHeadlines() -> Observable<[ArticleModel] > {
        return self.apiClient.fetchHeadlines()
            .debug()
            .map([ArticleModel].self, atKeyPath: "articles")
            .do(onNext: {[weak self] (models:[ArticleModel]) in
                guard let strongSelf = self else { return }
                do {
                    let result = strongSelf.realm.objects(ArticleModel.self)
                    try strongSelf.realm.write {
                        strongSelf.realm.delete(result)
                        strongSelf.realm.add(models)
                    }
                } catch {
                    print(error)
                }
            })
    }
    
    func observeArticles() -> Observable<(AnyRealmCollection<ArticleModel>, RealmChangeset?)> {
        let result = self.realm.objects(ArticleModel.self)
        return Observable.changeset(from: result)
    }
}
