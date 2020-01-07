//
// Created by sergdort on 03/02/2017.
// Copyright (c) 2017 sergdort. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ErrorTracker: SharedSequenceConvertibleType {
    typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<Error>()

    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.E> {
        return source.asObservable().do(onError: onError)
    }

    func asSharedSequence() -> SharedSequence<SharingStrategy, Error> {
        return _subject.asObservable().asDriverOnErrorJustComplete()
    }

    func asObservable() -> Observable<Error> {
        return _subject.asObservable()
    }
    
    func raiseError(_ error: Error) {
        print(error)
        _subject.onNext(error)
    }
    
    private func onError(_ error: Error) {
        _subject.onNext(error)
    }
    
    deinit {
        _subject.onCompleted()
    }
}

extension ObservableConvertibleType {
    func trackError(_ errorTracker: ErrorTracker) -> Observable<E> {
        return errorTracker.trackError(from: self)
    }
}

extension ObservableType {
 
    // 抓到 error，做一些處理後就結束整個 sequence
    func catchErrorJustComplete( handler: @escaping ((NSError) throws -> Void) ) -> Observable<E> {
        return catchError { (error) in
            do {
                try handler(error as NSError)
            } catch {
                throw error
            }
            return Observable.empty()
        }
    }
    
    // 抓到 error 就結束整個 sequence
    func catchErrorJustComplete() -> Observable<E> {
        return catchError { (error) in
            return Observable.empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<E> {
        return asDriver { error in
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
    func retry( maxRetry: Int, retryInterval: Double ) -> Observable<E> {
        return retryWhen { errors in
            return errors.enumerated().flatMap { (arg) -> Observable<Int64> in
                let (index, error) = arg
                return index <= maxRetry ? Observable<Int64>.timer(RxTimeInterval(retryInterval), scheduler: MainScheduler.instance) : Observable.error(error)
            }
        }
    }
    
    func retryPowInterval( maxRetry: Int, multiple: Double ) -> Observable<E> {
        return retryWhen { errors in
            return errors.enumerated().flatMap { (arg) -> Observable<Int64> in
                let (index, error) = arg
                return index <= maxRetry ? Observable<Int64>.timer(RxTimeInterval( pow( multiple, Double(index)) ), scheduler: MainScheduler.instance) : Observable.error(error)
            }
        }
    }
    
}
