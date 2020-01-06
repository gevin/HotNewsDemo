//
//  NewsDetailViewModel.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/25.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
import RealmSwift
import Realm

protocol NewsDetailViewModelType: ViewModelType {
    
    // input
    func changeContent(_ newContent: String)
    func back() 
    
    // output
    var newsImage: Driver<ImageState> {get}
    var newsTitle: Driver<String> {get}
    var newsAuthor: Driver<String> {get}
    var newsContent: Driver<String> {get}
}

class NewsDetailViewModel: NewsDetailViewModelType {

    var coordinator: NewsDetailCoordinator
    var newsInteractor: NewsInteractorType
    let imageInteractor: ImageInteractorType
    
    private var _newsImage   = BehaviorRelay<ImageState>(value: .none)
    private var _newsTitle   = BehaviorRelay<String>(value: "")
    private var _newsAuthor  = BehaviorRelay<String>(value: "")
    private var _newsContent = BehaviorRelay<String>(value: "")
    
    var newsId: String = ""
    var notifyToken: NotificationToken? = nil
    
    var disposeBag = DisposeBag()
    
    deinit {
        notifyToken?.invalidate()
        print("NewsDetailViewModel dealloc")
    }

    init(coordinator: NewsDetailCoordinator, newsInteractor: NewsInteractorType, imageInteractor: ImageInteractorType, newsId: String ) {
        self.coordinator = coordinator
        self.newsInteractor = newsInteractor
        self.imageInteractor = imageInteractor
        self.newsId = newsId
    }
    
    func initial() {
        if let model = self.newsInteractor.getArticleModel(newsId: self.newsId) {
            notifyToken = model.observe {[weak self] (change:ObjectChange) in
                guard let strongSelf = self else {return}
                switch change {
                case .change(let properties):
                    for property in properties {
                        switch property.name {
                        case "title":
                            strongSelf._newsTitle.accept(property.newValue as! String)
                        case "author":
                            strongSelf._newsAuthor.accept(property.newValue as! String)
                        case "content":
                            strongSelf._newsContent.accept(property.newValue as! String)
                        default: break
                        }
                    }
                case .error(let error):
                    print("An error occurred: \(error)")
                case .deleted:
                    strongSelf.notifyToken?.invalidate()
                    strongSelf.notifyToken = nil
                }
            }
            self._newsContent.accept(model.content)
            self._newsTitle.accept(model.title)
            self._newsAuthor.accept(model.author)
            
            
            if model.urlToImage.count > 0 {
                imageInteractor.getImage(urlString: model.urlToImage)
                    .bind(to: self._newsImage)
                    .disposed(by: self.disposeBag)
            }
        }
    }
    
    func refresh() {
        if let model = self.newsInteractor.getArticleModel(newsId: self.newsId) {
            self._newsContent.accept(model.content)
            self._newsTitle.accept(model.title)
            self._newsAuthor.accept(model.author)

            if model.urlToImage.count > 0 {
                imageInteractor.getImage(urlString: model.urlToImage)
                    .bind(to: self._newsImage)
                    .disposed(by: self.disposeBag)
            }
        }
    }
}

// MARK: - Input 

extension NewsDetailViewModel {
    
    func changeContent(_ newContent: String) {
        if let model = self.newsInteractor.getArticleModel(newsId: self.newsId) {
            self.newsInteractor.updateArticleContent(model: model, newContent: newContent)
        }
    }
    
    func back() {
        
    }
}

// MARK: - Output

extension NewsDetailViewModel {
    var newsImage: Driver<ImageState> {return self._newsImage.asDriver()}
    var newsTitle: Driver<String> {return self._newsTitle.asDriver()}
    var newsAuthor: Driver<String> {return self._newsAuthor.asDriver()}
    var newsContent: Driver<String> {return self._newsContent.asDriver()}
}
