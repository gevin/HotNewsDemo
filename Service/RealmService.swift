//
//  RealmService.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2020/1/6.
//  Copyright © 2020 GevinChen. All rights reserved.


import RealmSwift
import Realm
import RxSwift
import RxCocoa

protocol RealmServiceType {
    
    func observe<T: Object>(_ type: T.Type) -> Observable<RealmCollectionChange<Results<T>>>
    func observeObject<T: Object>(_ object: T ) -> Observable<ObjectChange>
    func getRealm() -> Realm 
    
//    func objects<T: Object>(_ type: T.Type) -> [T]
//    func object<T: Object, KeyType>( ofType type: T.Type, forPrimaryKey key: KeyType) -> T?
//    
//    func write(_ block:() -> Void )
//    func add<T: Object>(_ object: T)
//        
//    func add<T: Object>(_ objects: [T])
//    func add<T: Object>(_ object: T, update: Realm.UpdatePolicy)
//    func add<T: Object>(_ objects: [T], update: Realm.UpdatePolicy)
//    func delete<T: Object>(_ object: T)
//    func delete<T: Object>(_ objects: [T])
//    func delete<T: Object>(_ objects: Results<T>)
//    func delete<T: Object>(_ objects: LinkingObjects<T>)
//    func deleteAll() 
}

class RealmService: RealmServiceType {
    
    public var config: Realm.Configuration?
    
    private var _realm: Realm
    
//    private var _bg_realm: Realm?
    
    let bg_queue = DispatchQueue.global(qos: .background)
    
    init(config configOpt: Realm.Configuration?, name: String ) {
        var dbPath = ""
        if let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            dbPath = "\(docPath)/\(name).realm"
        }
        
        if let config = configOpt {
            Realm.Configuration.defaultConfiguration = config
            self.config = config
            Realm.Configuration.defaultConfiguration.fileURL = URL(fileURLWithPath: dbPath)
             self.config?.fileURL = URL(fileURLWithPath: dbPath)
            try! _realm = Realm(configuration: self.config!)
        } else {
            try! _realm = Realm()
        }
        print("realm db:\(_realm.configuration.fileURL?.absoluteString ?? "")")

    }
    
    func getRealm() -> Realm {
        if Thread.isMainThread {
            return self._realm
        } else {
            if self.config != nil {
                let realm = try! Realm(configuration: self.config!)
                return realm
            } else {
                let realm = try! Realm()
                return realm
            }
        }
    }
    
    func observe<T: Object>(_ type: T.Type) -> Observable<RealmCollectionChange<Results<T>>> {
        let result = self._realm.objects(type)
        return Observable.create { (observer:AnyObserver<RealmCollectionChange<Results<T>>>) -> Disposable in
            let token = result.observe { (changes:RealmCollectionChange<Results<T>>) in
                observer.onNext(changes)
            }
            return Disposables.create {
                token.invalidate()
            }
        }
    }
    
    func observeObject<T: Object>(_ object: T ) -> Observable<ObjectChange> {
        return Observable.create { (observer:AnyObserver<ObjectChange>) -> Disposable in
            var token: NotificationToken?
            token = object.observe { (change:ObjectChange) in
                switch change {
                case .error(_):
                    observer.onNext(change)
                case .change(_):
                    observer.onNext(change)
                case .deleted:
                    observer.onNext(change)
                    token?.invalidate()
                    observer.onCompleted()
                }
            }
            return Disposables.create {
                token?.invalidate()
            } 
        }
    }
    
    
//    func write(_ block:() -> Void ) {
//        let realm = self.getRealm()
//        try! realm.write {
//            block()
//        }
//        _bg_realm = nil
//    }
//    
//    // query object in background
//    func objects<T: Object>(_ type: T.Type) -> [T] {
//        let realm = self.getRealm()
//        let result = realm.objects(type)
//        return result.toArray()
//    }
//    
//    func object<T: Object, KeyType>( ofType type: T.Type, forPrimaryKey key: KeyType) -> T? {
//        let realm = self.getRealm()
//        let model = realm.object(ofType: type, forPrimaryKey: key)
//        return model
//    }
//    
//    func add<T: Object>(_ object: T) {
//        let realm = self.getRealm()
//        realm.add(object)
//    }
//    
//    func add<T: Object>(_ objects: [T]) {
//        let realm = self.getRealm()
//        realm.add(objects)
//    }
//
//    /// add or update a data
//    func add<T: Object>(_ object: T, update: Realm.UpdatePolicy) {
//        let realm = self.getRealm()
//        realm.add(object, update: update)
//    }
//
//    func add<T: Object>(_ objects: [T], update: Realm.UpdatePolicy) {
//        let realm = self.getRealm()
//        realm.add(objects, update: update)
//    }
//    
//    func delete<T: Object>(_ object: T) {
//        let realm = self.getRealm()
//        realm.delete(object)
//    }
//
//    func delete<T: Object>(_ objects: [T]) {
//        let realm = self.getRealm()
//        realm.delete(objects)
//    }
//
//    func delete<T: Object>(_ objects: Results<T>) {
//        let realm = self.getRealm()
//        realm.delete(objects)
//    }
//    
//    func delete<T: Object>(_ objects: LinkingObjects<T>) {
//        let realm = self.getRealm()
//        realm.delete(objects)
//    }
//    
//    func deleteAll() {
//        let realm = self.getRealm()
//        realm.deleteAll()
//    }
    
}
