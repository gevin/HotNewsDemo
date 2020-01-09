//
//  MockImageInteractor.swift
//  HotNewsDemoTests
//
//  Created by GevinChen on 2020/1/8.
//  Copyright © 2020 GevinChen. All rights reserved.
//

@testable import HotNewsDemo
import RxSwift
import RxCocoa

class MockImageInteractor: ImageInteractorType {
    
    var result:[UIImage] = []
    var currentIdx = 0
    
    init() {
        result.append(UIImage(named: "clock.png")!)
        result.append(UIImage(named: "architecture-and-city.png")!)
        result.append(UIImage(named: "baby-shower.png")!)
        result.append(UIImage(named: "food-and-restaurant.png")!)
        result.append(UIImage(named: "furniture-and-household.png")!)
    }
    
    func getImage( urlString: String ) -> Observable<ImageState> {
        let image = result[currentIdx]
        currentIdx = (currentIdx + 1) % result.count  
        return Observable.of(ImageState.completed(image))
//        return Observable.merge([Observable.of( ImageState.loading), Observable.of(ImageState.completed(image)).delay(1, scheduler: ConcurrentDispatchQueueScheduler(qos: .background)) ])
//        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}
