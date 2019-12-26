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

class NewsDetailCoordinator: NSObject, CoordinatorType {
    
    weak var viewController: UIViewController?
    var childCoordinators: [CoordinatorType] = []
    private var _navigationController: UINavigationController?

    let apiClient: APIClient
    let realm: Realm 
    let newsId: String
    
    var didFinish = PublishSubject<CoordinatorType?>()
    var disposeBag = DisposeBag()
    
    deinit {
        print("NewsDetailCoordinator dealloc")
    }
    
    init( navigationController: UINavigationController?, apiClient: APIClient, realm: Realm, newsId: String ) {
        self._navigationController = navigationController
        self.apiClient = apiClient
        self.realm = realm
        self.newsId = newsId
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as? NewsDetailViewController else {
            print("")
            return
        }
        let imageInteractor = ImageInteractor(apiClient: apiClient, realm: realm)
        let newsInterctor = NewsInteractor(apiClient: apiClient, realm: realm)
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
