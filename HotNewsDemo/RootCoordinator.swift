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
    let realm: Realm 
    var disposeBag = DisposeBag()
    
    required init(window: UIWindow, navigationController: UINavigationController?, apiClient: APIClient, realm: Realm ) {
        self._window = window
        self._navigationController = navigationController
        self.apiClient = apiClient
        self.realm = realm
    }
    
    func start() {
        self.gotoHeadlines()
        self._window.rootViewController = self._navigationController
        self._window.makeKeyAndVisible()
    }
    
    func back() {
        
    }
    
    func gotoHeadlines() {
        let coordinator = HeadlinesCoordinator(navigationController: self._navigationController, apiClient: apiClient, realm: realm)
        coordinator.start()
    }
    
}
