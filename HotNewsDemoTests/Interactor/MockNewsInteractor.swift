//
//  MockNewsInteractor.swift
//  HotNewsDemoTests
//
//  Created by GevinChen on 2020/1/8.
//  Copyright © 2020 GevinChen. All rights reserved.
//

import RxSwift
import RxCocoa
import Realm
import RealmSwift
import RxRealm
@testable import HotNewsDemo

class MockNewsInteractor: NewsInteractor {
    
    // 方便控制輸出的結果
    var fetchNextReslt: [ArticleModel] = []
    
    var reloadResult: [ArticleModel] = []
    
    var currentPage: Int = 0
    
    init() {
        super.init(apiService: MockAPIService(), realmService: MockRealmService() )
    }
    
    override func getCurrentPage() -> Int {
        return currentPage
    }
    
    override func fetchNextNewsHeadlines() -> Observable<[ArticleModel]> {
        return Observable.of(fetchNextReslt).delay(2, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    override func reloadNewsHeadlines() -> Observable<[ArticleModel]> {
        return Observable.of(reloadResult).delay(2, scheduler: ConcurrentDispatchQueueScheduler(qos: .background) )
    }
    
}
