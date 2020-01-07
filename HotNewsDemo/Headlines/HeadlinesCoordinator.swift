//
//  HeadlinesCoordinator.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/26.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift

class HeadlinesCoordinator: CoordinatorType {

    weak var viewController: UIViewController?
    var childCoordinators: [CoordinatorType] = []
    private var _navigationController: UINavigationController?
    
    let apiClient: APIClient
    let realmService: RealmService
    
    var disposeBag = DisposeBag()
    
    init( navigationController: UINavigationController?, apiClient: APIClient, realmService: RealmService ) {
        self._navigationController = navigationController
        self.apiClient = apiClient
        self.realmService = realmService
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "HeadlinesViewController") as? HeadlinesViewController else {
            fatalError("HeadlinesViewController does not exist in storyboard.")
        }
        let imageInteractor = ImageInteractor(apiClient: apiClient, realmService: realmService)
        let newsInterctor = NewsInteractor(apiClient: apiClient, realmService: realmService)
        let viewModel = HeadlinesViewModel(coordinator: self, newsInteractor: newsInterctor, imageInteractor: imageInteractor)
        vc.viewModel = viewModel
        self.viewController = vc
        self._navigationController?.pushViewController( vc, animated: false)
    }
    
    func back() {
        
    }
    
    func gotoNewsDetail( newsId: String ) {
        let nextCoordinator = NewsDetailCoordinator(navigationController: self._navigationController, apiClient: apiClient, realmService: realmService, newsId: newsId)
        self.childCoordinators.append(nextCoordinator)
        nextCoordinator.start()
        nextCoordinator.didFinish.subscribe(onNext: { (coordinatorOrNil:CoordinatorType?) in
            guard let coordinator = coordinatorOrNil else { return }
            if let index = self.childCoordinators.firstIndex(where: { ($0 === coordinator ) }) {
                self.childCoordinators.remove(at: index)
            }
        })
        .disposed(by: disposeBag)
    }
}
