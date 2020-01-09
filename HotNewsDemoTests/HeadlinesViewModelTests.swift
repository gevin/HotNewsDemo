//
//  HotNewsDemoTests.swift
//  HotNewsDemoTests
//
//  Created by GevinChen on 2020/1/8.
//  Copyright © 2020 GevinChen. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import Moya
import Alamofire

@testable import HotNewsDemo

class HeadlinesViewModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func loadImage(named name: String, type:String = "png") throws -> UIImage {
        let bundle = Bundle(for: self.classForCoder)
        guard let path = bundle.path(forResource: name, ofType: type) else {
            throw NSError(domain: "loadImage", code: 1, userInfo: nil)
        }
        guard let image = UIImage(contentsOfFile: path) else {
            throw NSError(domain: "loadImage", code: 2, userInfo: nil)
        }
        return image
    }
    
    func loadModel() throws -> [ArticleModel] {
        let testBundle = Bundle(for: type(of: self))
        let jsonPath = testBundle.path(forResource: "headlines", ofType: "json")
        let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath!))
        let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
        let modelArrayData = try JSONSerialization.data(withJSONObject: dict["articles"], options: JSONSerialization.WritingOptions.prettyPrinted)
        let decoder = JSONDecoder()
        let modelArray = try decoder.decode([ArticleModel].self, from: modelArrayData)
        return modelArray
    }

    // 測有撈到資料
    func testFetchFirstPage() {
        var disposeBag = DisposeBag()
        let realmConfig = Realm.Configuration(schemaVersion: 0, migrationBlock: nil)
        let realmService = RealmService(config: realmConfig, name: "test")
        let realm = realmService.getRealm()
        try! realm.write {
            realm.deleteAll()
        }
        let apiService = MockAPIService()
        let coordinator = MockHeadlinesCoordinator()
        let newsInteractor = NewsInteractor(apiService: apiService, realmService: realmService)
        let imageInteractor = ImageInteractor(apiService: apiService, realmService: realmService)
        let viewModel = HeadlinesViewModel(coordinator: coordinator, newsInteractor: newsInteractor, imageInteractor: imageInteractor)
        
        do {
            // initial fake data
            let modelArray = try self.loadModel()
            apiService.totalData = modelArray
            
            // initial fake image
            apiService.images.append( try! self.loadImage(named: "clock") )
            apiService.images.append( try! self.loadImage(named: "architecture-and-city") )
            apiService.images.append( try! self.loadImage(named: "baby-shower") )
            apiService.images.append( try! self.loadImage(named: "food-and-restaurant") )
            apiService.images.append( try! self.loadImage(named: "furniture-and-household") )
        } catch {
            XCTFail("load data fail.")
        }
        
        var dataCount = apiService.pageSize

        // at begin, realm should be empty.
        let result = realm.objects(ArticleModel.self)
        if result.count > 0 {
            XCTFail("there were some data in realm before testing.")
        }
        
        // 載入第一頁
        viewModel.initial()
        
        // receive data
        let dataShouldLoaded = expectation(description: "load data")
        viewModel.articleList
            .skip(1)
            .drive(onNext: { (list:[ArticleListViewModel]) in
                if list.count == 0 {
                    XCTFail()
                } else {
                    XCTAssert( list.count == dataCount )
                    dataShouldLoaded.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        // error
        viewModel.error
            .drive(onNext: { (error:Error) in
                XCTFail()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    // 測撈到空資料
    func testFetchEmptyData() {
        var disposeBag = DisposeBag()
        let realmConfig = Realm.Configuration(schemaVersion: 0, migrationBlock: nil)
        let realmService = RealmService(config: realmConfig, name: "test")
        let realm = realmService.getRealm()
        try! realm.write {
            realm.deleteAll()
        }
        let apiService = MockAPIService()
        let coordinator = MockHeadlinesCoordinator()
        let newsInteractor = NewsInteractor(apiService: apiService, realmService: realmService)
        let imageInteractor = ImageInteractor(apiService: apiService, realmService: realmService)
        let viewModel = HeadlinesViewModel(coordinator: coordinator, newsInteractor: newsInteractor, imageInteractor: imageInteractor)

        // at begin, realm should be empty.
        let result = realm.objects(ArticleModel.self)
        if result.count > 0 {
            XCTFail("there were some data in realm before testing.")
        }

        // 初始
        viewModel.initial()
        
        // receive data
        let dataShouldLoaded = expectation(description: "load data")
        viewModel.articleList
            .skip(1)
            .drive(onNext: { (list:[ArticleListViewModel]) in
                if list.count == 0 {
                    dataShouldLoaded.fulfill()
                } else {
                    XCTFail()
                }
            })
            .disposed(by: disposeBag)
        
        // error
        viewModel.error
            .drive(onNext: { (error:Error) in
                XCTFail()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    // 撈資料時，發生錯誤
    func testFetchDataErrorOccur() {
        
        var disposeBag = DisposeBag()
        let realmConfig = Realm.Configuration(schemaVersion: 0, migrationBlock: nil)
        let realmService = RealmService(config: realmConfig, name: "test")
        let realm = realmService.getRealm()
        try! realm.write {
            realm.deleteAll()
        }
        let apiService = MockAPIService()
        let coordinator = MockHeadlinesCoordinator()
        let newsInteractor = NewsInteractor(apiService: apiService, realmService: realmService)
        let imageInteractor = ImageInteractor(apiService: apiService, realmService: realmService)
        let viewModel = HeadlinesViewModel(coordinator: coordinator, newsInteractor: newsInteractor, imageInteractor: imageInteractor)
        
        // 指定輸出錯誤
        enum TestError: Error {
            case testError(String)
        }
        apiService.error = MoyaError.underlying(TestError.testError("test error"), nil)
        
        // at begin, realm should be empty.
        let result = realm.objects(ArticleModel.self)
        if result.count > 0 {
            XCTFail("there were some data in realm before testing.")
        }
        
        // 初始
        viewModel.initial()
        
        // error
        let shouldError = expectation(description: "should error")
        viewModel.error
            .drive(onNext: { (error:Error) in
                print(error)
                shouldError.fulfill()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    // 撈資料時，必須呈現 loading 狀態
    func testFetchDataShouldBeInLoading() {
        var disposeBag = DisposeBag()
        let realmConfig = Realm.Configuration(schemaVersion: 0, migrationBlock: nil)
        let realmService = RealmService(config: realmConfig, name: "test")
        let realm = realmService.getRealm()
        try! realm.write {
            realm.deleteAll()
        }
        let apiService = MockAPIService()
        let coordinator = MockHeadlinesCoordinator()
        let newsInteractor = NewsInteractor(apiService: apiService, realmService: realmService)
        let imageInteractor = ImageInteractor(apiService: apiService, realmService: realmService)
        let viewModel = HeadlinesViewModel(coordinator: coordinator, newsInteractor: newsInteractor, imageInteractor: imageInteractor)
        
        let pageSize = 10
        do {
            // initial fake data
            let modelArray = try self.loadModel()
            apiService.totalData = modelArray
            apiService.pageSize = pageSize
            
            // initial fake image
            apiService.images.append( try! self.loadImage(named: "clock") )
            apiService.images.append( try! self.loadImage(named: "architecture-and-city") )
            apiService.images.append( try! self.loadImage(named: "baby-shower") )
            apiService.images.append( try! self.loadImage(named: "food-and-restaurant") )
            apiService.images.append( try! self.loadImage(named: "furniture-and-household") )
        } catch {
            XCTFail("load data fail.")
        }
        
        let shouldBeInLoading = expectation(description: "loading")
        let shouldLoadSecondPage = expectation(description: "load second page")
        
        var subdisposeBag = DisposeBag()
        let loadingFirstPage = Observable.create { (observer:AnyObserver<Void>) -> Disposable in
            // 載入第一頁
            viewModel.initial()
            viewModel.articleList
                .skip(1)
                .drive(onNext: { (list:[ArticleListViewModel]) in
                    if list.count == pageSize * viewModel.loadedPages {
                        observer.onNext(())
                        observer.onCompleted()
                    } else {
                        XCTFail()
                    }
                })
                .disposed(by: subdisposeBag)
            return Disposables.create{subdisposeBag = DisposeBag()}
        }
        
        var subdisposeBag2 = DisposeBag()
        let loadingNextPage = Observable.create { (observer:AnyObserver<Void>) -> Disposable in
            // 載入下一頁
            viewModel.loadNextPage()
            
            // loading state should be true
            viewModel.loading
                .drive(onNext: { (isLoading:Bool) in
                    if isLoading {
                        // 當載入下一頁時，狀態必須是 loading
                        shouldBeInLoading.fulfill()
                    } else {
                        XCTFail("It's not in loading state while fetch data.")
                    }
                })
                .dispose()
            
            // receive data
            viewModel.articleList
                .skip(1)
                .drive(onNext: { (list:[ArticleListViewModel]) in
                    if list.count == pageSize * viewModel.loadedPages {
                        observer.onNext(())
                        observer.onCompleted()
                        shouldLoadSecondPage.fulfill()
                    } else {
                        XCTFail()
                    }
                })
                .disposed(by: subdisposeBag2)
            
            return Disposables.create{subdisposeBag2 = DisposeBag()}
        }
        
        // 先執行載入第一頁完成，再執行載入第二頁
        loadingFirstPage
            .flatMap { loadingNextPage }
            .subscribe()
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 20, handler: nil) // this line will block thread, holding on this position.
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
