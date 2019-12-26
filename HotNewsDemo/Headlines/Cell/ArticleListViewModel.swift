//
//  ArticleListViewModel.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/24.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

struct ArticleListViewModel: IdentifiableType, Equatable {
    
    var identity: String
    var imageUrl: String
    var image: BehaviorRelay<ImageState> 
    var content: BehaviorRelay<String>
    init() {
        self.image = BehaviorRelay<ImageState>(value: .none)
        self.content = BehaviorRelay<String>(value: "")
        self.imageUrl = ""
        self.identity = ""
    }
    
    // MARK: - Equatable
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.imageUrl == rhs.imageUrl && lhs.content.value == rhs.content.value {
            return true
        }
        return false
    }
}
