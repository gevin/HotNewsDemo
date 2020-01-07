//
//  Coordinator.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/24.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Realm
import RealmSwift

protocol CoordinatorType: AnyObject {
    var viewController: UIViewController? { get }
    var childCoordinators: [CoordinatorType] { get } 
    func start()
    func back()
}

class BaseCoordinator: CoordinatorType {
    var viewController: UIViewController?
    var childCoordinators: [CoordinatorType] = []
    func start() {
        fatalError("Start method must be implemented")
    }
    
    func back() {
        
    }
}

protocol ViewModelType {
    func initial()
    func refresh()
}

protocol ViewType {
    associatedtype ViewModelType
    var viewModel: ViewModelType? { get }
}

protocol InteractorType {
    var apiClient: APIClient { get }
    var realmService: RealmService { get }
}
