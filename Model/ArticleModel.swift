//
//  NewsHeadlineModel.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/19.
//Copyright © 2019 GevinChen. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ArticleModel: Object, Codable {
    
    override static func primaryKey() -> String? {
        return "newsId"
    }
    static var genId = 0
    @objc dynamic var newsId: String = "" // 我自己添加的
    @objc dynamic var source: ArticleSourceModel?
    @objc dynamic var author: String = "" //"Sean Hollister",
    @objc dynamic var title: String = "" //"Is this Samsung’s next Galaxy Fold? - Circuit Breaker",
    @objc dynamic var newsDescription: String = "" // "Samsung’s Galaxy Fold has the dubious honor of being the first folding phone most of our readers could actually buy — but it won’t be the last. Now, images are floating around Chinese social media of a phone that looks like it could very well be Samsung’s nex…",
    @objc dynamic var url: String = "" // "https://www.theverge.com/circuitbreaker/2019/12/19/21029477/samsung-new-galaxy-fold-clamshell-leaked-images",
    @objc dynamic var urlToImage: String = "" //"https://cdn.vox-cdn.com/thumbor/oD9HSc1FSYFb-t7Gh7eu-xtIfLM=/0x219:1278x888/fit-in/1200x630/cdn.vox-cdn.com/uploads/chorus_asset/file/19541463/galaxy_fold_clamshell_rumored_2.jpg",
    @objc dynamic var publishedAt: String = "" // "2019-12-19T07:24:24Z",
    @objc dynamic var content: String = "" // "via Weibo\r\nSamsungs Galaxy Fold has the dubious honor of being the first folding phone most of our readers could actually buy but it wont be the last. Last month, Motorola announced a vertically folding throwback to its classic RAZR, and Samsung has teased th… [+1952 chars]"
    
    private enum CodingKeys: String, CodingKey {
        case source
        case author
        case title 
        case newsDescription = "description"
        case url
        case urlToImage
        case publishedAt
        case content
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
        self.source          = try? container.decode(ArticleSourceModel.self, forKey: .source)
        self.author          = try container.decodeIfPresent(String.self, forKey: .author         ) ?? ""
        self.title           = try container.decodeIfPresent(String.self, forKey: .title          ) ?? ""
        self.newsDescription = try container.decodeIfPresent(String.self, forKey: .newsDescription) ?? ""
        self.url             = try container.decodeIfPresent(String.self, forKey: .url            ) ?? ""
        self.urlToImage      = try container.decodeIfPresent(String.self, forKey: .urlToImage     ) ?? ""
        self.publishedAt     = try container.decodeIfPresent(String.self, forKey: .publishedAt    ) ?? ""
        self.content         = try container.decodeIfPresent(String.self, forKey: .content        ) ?? ""
        self.newsId          = "\(author),\(title),\(publishedAt)".MD5().base64EncodedString()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode( self.source           , forKey: .source          )
        try container.encode( self.author           , forKey: .author          )         
        try container.encode( self.title            , forKey: .title           )
        try container.encode( self.newsDescription  , forKey: .newsDescription )
        try container.encode( self.url              , forKey: .url             )
        try container.encode( self.urlToImage       , forKey: .urlToImage      )
        try container.encode( self.publishedAt      , forKey: .publishedAt     )
        try container.encode( self.content          , forKey: .content         )
    }
}

