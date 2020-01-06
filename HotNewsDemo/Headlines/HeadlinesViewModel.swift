//
//  HeadlinesViewModel.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/24.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import Realm
import SDWebImage

protocol HeadlinesViewModelType: ViewModelType {
    
    // input 
    func selectArticle( articleVM: ArticleListViewModel )
    
    // output
    var articleList: Driver<[ArticleListViewModel]> {get}
    var loading: Driver<Bool> {get}
    var error: Driver<Error> {get}
}

class HeadlinesViewModel: HeadlinesViewModelType {

    let coordinator: HeadlinesCoordinator
    let newsInteractor: NewsInteractorType
    let imageInteractor: ImageInteractor
    private var _loadingTrack   = ActivityIndicator()
    private var _errorTrack     = ErrorTracker()
    private var _articleVMs     = BehaviorRelay<[ArticleListViewModel]>(value: [])
    private var _articleModels  = [ArticleModel]()
    var disposeBag              = DisposeBag()
    
    deinit {
        
    }
    
    init( coordinator: HeadlinesCoordinator, newsInteractor: NewsInteractorType, imageInteractor: ImageInteractor) {
        self.coordinator   = coordinator
        self.newsInteractor = newsInteractor
        self.imageInteractor = imageInteractor
    }
    
    /// ViewModel initial
    func initial() {
        // observe changes of Article 
        self.newsInteractor.observeArticles()
            .subscribe(onNext: {[weak self] (results:AnyRealmCollection<ArticleModel>, changesOrNil:RealmChangeset?) in
                guard let strongSelf = self else {return}
                if let changes = changesOrNil {
//                    print("result: \(results)")
//                    print("deleted: \(changes.deleted)")
//                    print("inserted: \(changes.inserted)")
//                    print("updated: \(changes.updated)")
                    strongSelf.updateModels( results.toArray() )
                } else {
                        strongSelf.updateModels( results.toArray() )
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateModels(_ models:[ArticleModel] ) {
        // 新的在前
        var array = models.sorted { (m1, m2) -> Bool in
            return m1.publishedAt > m2.publishedAt
        }
        self._articleModels = array
        let cellVMs = self.mapCellViewModel( self._articleModels)
        self._articleVMs.accept(cellVMs)             
    }
    
    /// Update local model array
    /// - Parameter models: ArticleModel array
    private func addModels(_ models:[ArticleModel] ) {
        // 新的在前
        var array = models.sorted { (m1, m2) -> Bool in
            return m1.publishedAt > m2.publishedAt
        }
        self._articleModels = array
        let cellVMs = self.mapCellViewModel( self._articleModels)
        self._articleVMs.accept(cellVMs)     
    }
    
    /// Model -> ViewModel
    /// - Parameter models: ArticleModel array
    private func mapCellViewModel(_ models:[ArticleModel] ) -> [ArticleListViewModel] {
        let cellVMs = models.map { (model:ArticleModel) -> ArticleListViewModel in
            var cellVM = ArticleListViewModel()
            cellVM.identity = model.newsId
            cellVM.imageUrl = model.urlToImage
            cellVM.content.accept( model.content )
            // download image 
            if cellVM.imageUrl.count > 0 {
                imageInteractor.getImage(urlString: cellVM.imageUrl)
                    .bind(to: cellVM.image)
                    .disposed(by: disposeBag)
            }
            return cellVM
        }
        return cellVMs
    }
}

// MARK: - input

extension HeadlinesViewModel {
    
    func selectArticle(articleVM: ArticleListViewModel) {
        // move to detail
        self.coordinator.gotoNewsDetail(newsId: articleVM.identity)
    }
    
    /// It would be clear all ArticleModel data in Realm and refetch data from server.
    func refresh() {
        // fetch news headlines
        self.newsInteractor.reloadNewsHeadlines()
            .trackActivity(self._loadingTrack)
            .trackError(self._errorTrack)
            .subscribe(onNext: {[weak self] (results:[ArticleModel]) in
                guard let strongSelf = self else {return}
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - output

extension HeadlinesViewModel {
    
    var articleList: Driver<[ArticleListViewModel]> { return _articleVMs.asDriver() }
    var loading: Driver<Bool> { return self._loadingTrack.asDriver() }
    var error: Driver<Error> { return self._errorTrack.asDriver()}
    
}
