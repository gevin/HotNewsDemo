
//
//  MyDataSource.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/31.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// notify reloadData completed event

final class MyTableDataSource<S: AnimatableSectionModelType> : RxTableViewSectionedReloadDataSource<S> {
    private let relay = PublishRelay<Event<[S]>>()
    var dataReloded: Signal<Event<[S]>> {
        return relay.asSignal()
    }
    override func tableView(_ tableView: UITableView, observedEvent: Event<[S]>) {
        super.tableView(tableView, observedEvent: observedEvent)
        //Notify update
        relay.accept(observedEvent)
    }
}

final class MyTableAnimationDataSource<S: AnimatableSectionModelType> : RxTableViewSectionedAnimatedDataSource<S> {
    private let relay = PublishRelay<Event<[S]>>()
    var dataReloded: Signal<Event<[S]>> {
        return relay.asSignal()
    }
    override func tableView(_ tableView: UITableView, observedEvent: Event<[S]>) {
        super.tableView(tableView, observedEvent: observedEvent)
        //Notify update
        relay.accept(observedEvent)
    }
}

final class MyCollectionDataSource<S: AnimatableSectionModelType> : RxCollectionViewSectionedReloadDataSource<S> {
    private let relay = PublishRelay<Event<[S]>>()
    var dataReloded: Signal<Event<[S]>> {
        return relay.asSignal()
    }
    override func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[S]>) {
        super.collectionView(collectionView, observedEvent: observedEvent)
        //Notify update
        relay.accept(observedEvent)
    }
    
}

final class MyCollectionAnimationDataSource<S: AnimatableSectionModelType> : RxCollectionViewSectionedAnimatedDataSource<S> {
    private let relay = PublishRelay<Event<[S]>>()
    var dataReloded: Signal<Event<[S]>> {
        return relay.asSignal()
    }
    override func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[S]>) {
        super.collectionView(collectionView, observedEvent: observedEvent)
        //Notify update
        relay.accept(observedEvent)
    }
}
