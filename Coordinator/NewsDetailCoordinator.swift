//
//  NewsDetailCoordinator.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/25.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift

protocol NewsDetailCoordinatorType: CoordinatorType {
    
} 

class NewsDetailCoordinator: NSObject, NewsDetailCoordinatorType {
    
    weak var viewController: UIViewController?
    var childCoordinators: [CoordinatorType] = []
    private var _navigationController: UINavigationController?

    let apiService: APIServiceType
    let realmService: RealmService
    let newsId: String
    
    var didFinish = PublishSubject<CoordinatorType?>()
    var disposeBag = DisposeBag()
    
    deinit {
        print("NewsDetailCoordinator dealloc")
    }
    
    init( navigationController: UINavigationController?, apiService: APIServiceType, realmService: RealmService, newsId: String ) {
        self._navigationController = navigationController
        self.apiService = apiService
        self.realmService = realmService
        self.newsId = newsId
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as? NewsDetailViewController else {
            print("")
            return
        }
        let imageInteractor = ImageInteractor(apiService: apiService, realmService: realmService)
        let newsInterctor = NewsInteractor(apiService: apiService, realmService: realmService)
        let viewModel = NewsDetailViewModel(coordinator: self, newsInteractor: newsInterctor, imageInteractor: imageInteractor, newsId: newsId)
        vc.viewModel = viewModel
        self.viewController = vc
        self._navigationController?.pushViewController(vc, animated: true)
        
        vc.rx.viewWillDisappear
            .filter({[weak self] _ in (self?.viewController?.isMovingFromParent ?? false) })
            .map({[weak self] (_) -> CoordinatorType? in
                return self
            })
            .bind(to: didFinish)
            .disposed(by: self.disposeBag)
    }
    
    func back() {
        self._navigationController?.popViewController(animated: true)
    }
    

}
