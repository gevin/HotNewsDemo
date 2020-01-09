//
//  RLMResultsExtension.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/25.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Realm
import RealmSwift

extension Results {

    func toArray() -> [Element] {
        return compactMap { $0 }
    }
    
}
