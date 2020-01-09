//
//  MockAPIService.swift
//  HotNewsDemoTests
//
//  Created by GevinChen on 2020/1/8.
//  Copyright © 2020 GevinChen. All rights reserved.
//

@testable import HotNewsDemo
import RxCocoa
import RxSwift

class MockAPIService: APIServiceType {

    var error: Error?
    var totalData: [ArticleModel] = []
    var pageSize = 10
    var images:[UIImage] = []
    var currentIdx = 0
        
    init() {
        

    }
    
    func fetchHeadlines(page: Int) -> Observable<[ArticleModel]> {
        if let error = self.error {
            return Observable.error(error).delay(3, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        } else {
            let startIdx = (page - 1) * pageSize
            var endIdx = page * pageSize
            if endIdx > totalData.count {
                endIdx = totalData.count
            }
            let pageDatas = Array( totalData[startIdx..<endIdx] )
            return Observable.of(pageDatas).delay(3, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        }
    }
    
    func downloadImage(url: URL) -> Observable<ImageState> {
        let image = images[currentIdx]
        currentIdx = (currentIdx + 1) % images.count  
        return Observable.of(ImageState.completed(image))
    }


}
