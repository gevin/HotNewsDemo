//
//  NewsSourceModel.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/19.
//Copyright © 2019 GevinChen. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ArticleSourceModel: Object, Codable {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        self.id  = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
//        self.author          = try container.decode(String.self, forKey: .author         )
//        self.title           = try container.decode(String.self, forKey: .title          )
//        self.newsDescription = try container.decode(String.self, forKey: .newsDescription)
//        self.url             = try container.decode(String.self, forKey: .url            )
//        self.urlToImage      = try container.decode(String.self, forKey: .urlToImage     )
//        self.publishedAt     = try? container.decode(Date.self , forKey: .publishedAt    )
//        self.content         = try container.decode(String.self, forKey: .content        )
    }
    
}
