//
//  RootCoordinator.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/24.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift

class RootCoordinator: NSObject, CoordinatorType, UINavigationControllerDelegate {
    
    weak var viewController: UIViewController?
    var childCoordinators: [CoordinatorType] = []
    private var _navigationController: UINavigationController?
    private var _window: UIWindow
    
    let apiClient: APIClient
    let realmService: RealmService
    var disposeBag = DisposeBag()
    
    required init(window: UIWindow, navigationController: UINavigationController?, apiClient: APIClient, realmService: RealmService ) {
        self._window = window
        self._navigationController = navigationController
        self.apiClient = apiClient
        self.realmService = realmService
    }
    
    func start() {
        self.gotoHeadlines()
        self._window.rootViewController = self._navigationController
        self._window.makeKeyAndVisible()
    }
    
    func back() {
        
    }
    
    func gotoHeadlines() {
        let coordinator = HeadlinesCoordinator(navigationController: self._navigationController, apiClient: apiClient, realmService: realmService)
        coordinator.start()
    }
    
}
