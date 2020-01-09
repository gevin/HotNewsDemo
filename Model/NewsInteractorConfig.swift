//
//  NewsInteractorConfig.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2020/1/6.
//  Copyright © 2020 GevinChen. All rights reserved.
//

import Realm
import RealmSwift

class NewsInteractorConfig: Object {
    @objc dynamic var loadedPage: Int = 0
}
