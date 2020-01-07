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

class RealmService {
    
    public var config: Realm.Configuration
    
    public static var shared: RealmService! 
    
    private var _realm: Realm
    
    let bg_queue = DispatchQueue.global(qos: .background)
    
    static func initial( config: Realm.Configuration ) {
        self.shared = RealmService(config: config)
    }
    
    private init( config: Realm.Configuration ) {
        Realm.Configuration.defaultConfiguration = config
        self.config = config
        try! _realm = Realm(configuration: self.config)
        print("realm db:\(config.fileURL?.absoluteString ?? "")")
    }
    
    func getRealm() -> Realm {
        if Thread.isMainThread {
            return self._realm
        } else {
            let realm = try! Realm(configuration: self.config)
            return realm
        }
    }
    
    // query object in background
    func objects<T: Object>(_ type: T.Type) -> Observable<Results<T>> {
        Observable.create {[weak self] (observer:AnyObserver<Results<T>>) -> Disposable in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            do {
                let realm = try Realm(configuration: strongSelf.config)
                let result = realm.objects(type)
                observer.onNext(result)
                observer.onCompleted()
            } catch {
                observer.onError(error)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func object<T: Object, KeyType>( ofType type: T.Type, forPrimaryKey key: KeyType) -> Observable<T?> {
        Observable.create {[weak self] (observer:AnyObserver<T?>) -> Disposable in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            do {
                let realm = try Realm(configuration: strongSelf.config)
                let model = realm.object(ofType: type, forPrimaryKey: key)
                observer.onNext(model)
                observer.onCompleted()
            } catch {
                observer.onError(error)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
     
    func transaction(block: @escaping (Realm) -> Void ) -> Observable<Void> {
        return Observable.create {[weak self] (observer:AnyObserver<Void>) -> Disposable in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            do {
                var realm = Thread.isMainThread 
                    ? strongSelf._realm 
                    : try Realm(configuration: strongSelf.config)
                
                try realm.write {
                    block(realm)
                }
                
           } catch {
               observer.onError(error)
               observer.onCompleted()
           }
            return Disposables.create()
        }
    }
    
//    func objects<T: Object>(_ type: T.Type ) -> Results<T> {
//        if Thread.isMainThread {
//            return self._realm.objects(type)
//        } else {
//            let realm = try! Realm(configuration: self.config)
//            return realm.objects(type)
//        }
//    }
//    
//    func object<T: Object, KeyType>(ofType type: T.Type, forPrimaryKey key: KeyType ) -> T? {
//        if Thread.isMainThread {
//            return self._realm.object(ofType: type, forPrimaryKey: key)
//        } else {
//            let realm = try! Realm(configuration: self.config)
//            return realm.object(ofType: type, forPrimaryKey: key)
//        }
//    }
    
//    func write<T : ThreadConfined>(object: T, _ block: @escaping ((Realm, T) -> Void)) {
//        if Thread.isMainThread {
//            try! self._realm.write {
//                block(self._realm, object)
//            }
//        } else {
//            self.writeAsync(object: object, block)
//        }
//    }
//    
//    func writeAsync<T : ThreadConfined>(object: T,_ block: @escaping ((Realm, T) -> Void)) {
//        let objectRef = ThreadSafeReference(to: object)
//        bg_queue.async {
//            autoreleasepool {
//                let realm = try! Realm(configuration: self.config)
//                guard let object = realm.resolve(objectRef) else {return}
//
//                try! realm.write {
//                    block(realm, object)
//                }
//            }
//        }
//    }
    
//    func add<T: Object>(_ object: T) {
//        if Thread.isMainThread {
//            try! self._realm.write {
//                self._realm.add(object)
//            }
//        } else {
//            self.addAsync(object)
//        }
//    }
    
//    func addAsync<T: Object>(_ object: T) {
//        let objectRef = ThreadSafeReference(to: object)
//        bg_queue.async {
//            autoreleasepool {
//                let realm = try! Realm(configuration: self.config)
//                guard let object = realm.resolve(objectRef) else {
//                    return
//                }
//                try! realm.write {
//                    realm.add(object)
//                }
//            }
//        }
//    }
    
//    func add<T: Object>(_ objects: [T]) {
//        if Thread.isMainThread {
//            try! self._realm.write {
//                self._realm.add(objects)
//            }
//        } else {
//            self.addAsync(objects)
//        }
//    }
//    
//    func addAsync<T: Object>(_ objects: [T]) {
//        let list = List<T>()
//        list.append(objectsIn: objects)
//        let objectsRef = ThreadSafeReference(to: list)
//        bg_queue.async {
//            autoreleasepool {
//                let realm = try! Realm(configuration: self.config)
//                guard let objects = realm.resolve(objectsRef) else {
//                    return
//                }
//                try! realm.write {
//                    realm.add(objects)
//                }
//            }
//        }
//    }
//    
//    /// add or update a data
//    func add<T: Object>(_ object: T, update: Realm.UpdatePolicy) {
//        if Thread.isMainThread {
//            try! self._realm.write {
//                self._realm.add(object, update: update)
//            }
//        } else {
//            self.addAsync(object, update: update)
//        }
//    }
//    
//    func addAsync<T: Object>(_ object: T, update: Realm.UpdatePolicy) {
//        let objectRef = ThreadSafeReference(to: object)
//        bg_queue.async {
//            autoreleasepool {
//                let realm = try! Realm(configuration: self.config)
//                guard let object = realm.resolve(objectRef) else {
//                    return
//                }
//                try! realm.write {
//                    realm.add(object, update: update)
//                }
//            }
//        }
//    }
//    
//    func add<T: Object>(_ objects: [T], update: Realm.UpdatePolicy) {
//        if Thread.isMainThread {
//            try! self._realm.write {
//                self._realm.add(objects, update: update)
//            }
//        } else {
//            self.addAsync(objects, update: update)
//        }
//    }
//    
//    func addAsync<T: Object>(_ objects: [T], update: Realm.UpdatePolicy) {
//        let list = List<T>()
//        list.append(objectsIn: objects)
//        let objectsRef = ThreadSafeReference(to: list)
//        bg_queue.async {
//            autoreleasepool {
//                let realm = try! Realm(configuration: self.config)
//                guard let objects = realm.resolve(objectsRef) else {
//                    return
//                }
//                try! realm.write {
//                    realm.add(objects, update: update)
//                }
//            }
//        }
//    }
//    
//    /// 删除某个数据
//    func delete<T: Object>(_ object: T) {
//        if Thread.isMainThread {
//            try! self._realm.write {
//                self._realm.delete(object)
//            }
//        } else {
//            self.deleteAsync(object)
//        }
//    }
//    
//    func deleteAsync<T: Object>(_ object: T) {
//        let objectRef = ThreadSafeReference(to: object)
//        bg_queue.async {
//            autoreleasepool {
//                let realm = try! Realm(configuration: self.config)
//                guard let object = realm.resolve(objectRef) else {
//                    return
//                }
//                try! realm.write {
//                    realm.delete(object)
//                }
//            }
//        }
//    }
//    
//    /// 批量删除数据
//    func delete<T: Object>(_ objects: [T]) {
//        if Thread.isMainThread {
//            try! self._realm.write {
//                self._realm.delete(objects)
//            }
//        } else {
//            self.deleteAsync(objects)
//        }
//    }
//    
//    /// 批量删除数据
//    func deleteAsync<T: Object>(_ objects: [T]) {
//        let list = List<T>()
//        list.append(objectsIn: objects)
//        let objectsRef = ThreadSafeReference(to: list)
//        // Import many items in a background thread
//        bg_queue.async {
//            // 为什么添加下面的关键字，参见 Realm 文件删除的的注释
//            autoreleasepool {
//                // 在这个线程中获取 Realm 和表实例
//                let realm = try! Realm(configuration: self.config)
//                guard let objects = realm.resolve(objectsRef) else {
//                    return
//                }
//                try! realm.write {
//                    realm.delete(objects)
//                }
//            }
//        }
//    }
//    
//    /// 批量删除数据
//    func delete<T: Object>(_ objects: Results<T>) {
//        let array = objects.toArray()
//        self.delete(array)
//    }
//    
//    /// 批量删除数据
//    func delete<T: Object>(_ objects: LinkingObjects<T>) {
//        let array = objects.toArray()
//        self.delete(array)
//    }
//    
//    /// 删除所有数据。注意，Realm 文件的大小不会被改变，因为它会保留空间以供日后快速存储数据
//    func deleteAll() {
//        if Thread.isMainThread {
//            try! self._realm.write {
//                self._realm.deleteAll()
//            }
//        } else {
//            bg_queue.async {
//                autoreleasepool {
//                    let realm = try! Realm(configuration: self.config)
//                    try! realm.write {
//                        realm.deleteAll()
//                    }
//                }
//            }
//        }
//    }
    
}

extension ObservableType {

    func realmWrite(_ handler: @escaping (_ realm:Realm,_ object:E) -> Void) -> Observable<E> {
        
        return self.do(onNext: { (object:E) in
            do {
                let realm = try Realm(configuration: RealmService.shared.config)
                try realm.write {
                    handler(realm, object)
                }
            } catch {
                throw error
            }
        })
        
    }

}
