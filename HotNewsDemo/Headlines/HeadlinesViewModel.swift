//
//  HeadlinesViewModel.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/24.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift
import Realm
import SDWebImage

protocol HeadlinesViewModelType: ViewModelType {
    
    // input 
    func selectArticle( articleVM: ArticleListViewModel )
    func loadNextPage()
    func refresh()
    
    // output
    var articleList: Driver<[ArticleListViewModel]> {get}
    var loadedPages: Int {get}
    var loading: Driver<Bool> {get}
    var error: Driver<Error> {get}
}

class HeadlinesViewModel: HeadlinesViewModelType {

    let coordinator: HeadlinesCoordinatorType
    let newsInteractor: NewsInteractorType
    let imageInteractor: ImageInteractorType
    private var _loadingTrack   = ActivityIndicator()
    private var _errorTrack     = ErrorTracker()
    private var _articleVMs     = BehaviorRelay<[ArticleListViewModel]>(value: [])
    private var _articleModels  = [ArticleModel]()
    var disposeBag              = DisposeBag()
    
    deinit {
        
    }
    
    init( coordinator: HeadlinesCoordinatorType, newsInteractor: NewsInteractorType, imageInteractor: ImageInteractorType) {
        self.coordinator   = coordinator
        self.newsInteractor = newsInteractor
        self.imageInteractor = imageInteractor
    }
    
    /// ViewModel initial
    func initial() {
        // observe changes of Article 
        self.newsInteractor.observeArticles()
            .subscribe(onNext: {[weak self] (change) in
                guard let strongSelf = self else {return}
                switch change {
                case .initial(let collection):
                    if collection.count == 0 {
                        strongSelf.loadNextPage()
                    } else {
                        strongSelf.updateModels( collection.toArray() )
                    }
                case .update(let collection, let deletions, let insertions, let modifications):
                    strongSelf.updateModels( collection.toArray() )
                case .error(let error):
                    strongSelf._errorTrack.raiseError(error)
                }
            })
            .disposed(by: disposeBag)
//        self.loadNextPage()
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
    
    // fetch next page news
    func loadNextPage() {
        // fetch news headlines
        self.newsInteractor.fetchNextNewsHeadlines()
            .trackActivity(self._loadingTrack)
            .trackError(self._errorTrack)
            .subscribe(onNext: {[weak self] (results:[ArticleModel]) in
                guard let strongSelf = self else {return}
                // if results is empty collection, then realm notification will not trigger
                // but I still have to notify UI update, so I update array manaully
                if results.count == 0 {
                    strongSelf.updateModels(results)
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// It would be clear all ArticleModel data in Realm and refetch data from server.
    func refresh() {
        // fetch news headlines
        self.newsInteractor.reloadNewsHeadlines()
            .trackActivity(self._loadingTrack)
            .trackError(self._errorTrack)
            .subscribe(onNext: {[weak self] (results:[ArticleModel]) in
                guard let strongSelf = self else {return}
                // if results is empty collection, then realm notification will not trigger
                // but I still have to notify UI update, so I update array manaully
                if results.count == 0 {
                    strongSelf.updateModels(results)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - output

extension HeadlinesViewModel {
    
    var articleList: Driver<[ArticleListViewModel]> { return _articleVMs.asDriver() }
    var loading: Driver<Bool> { return self._loadingTrack.asDriver() }
    var error: Driver<Error> { return self._errorTrack.asDriver()}
    var loadedPages: Int { return self.newsInteractor.loadedPages() }
    
}
