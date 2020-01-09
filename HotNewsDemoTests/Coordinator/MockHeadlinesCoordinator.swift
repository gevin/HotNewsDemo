//
//  MockHeadlinesCoordinator.swift
//  HotNewsDemoTests
//
//  Created by GevinChen on 2020/1/8.
//  Copyright © 2020 GevinChen. All rights reserved.
//

import UIKit
@testable import HotNewsDemo

class MockHeadlinesCoordinator: HeadlinesCoordinatorType {
    
    weak var viewController: UIViewController?
    
    var childCoordinators: [CoordinatorType] = []
    
    func start() {
        
    }
    
    func back() {
        
    }
    
    func gotoNewsDetail(newsId: String) {
        
    }
    
}
