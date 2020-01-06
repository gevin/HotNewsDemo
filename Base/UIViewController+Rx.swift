//
//  UIViewController+Rx.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/26.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {

    var viewDidLoad: ControlEvent<Void> {
      let source = self.methodInvoked(#selector(Base.viewDidLoad))
        .map { _ in }
      return ControlEvent(events: source)
    }

    var viewWillAppear: ControlEvent<Bool> {
      let source = self.methodInvoked(#selector(Base.viewWillAppear))
        .map { $0[0] as? Bool ?? false }
      return ControlEvent(events: source)
    }
    
    var viewDidAppear: ControlEvent<Bool> {
      let source = self.methodInvoked(#selector(Base.viewDidAppear))
        .map { $0[0] as? Bool ?? false }
      return ControlEvent(events: source)
    }
    
    var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear))
            .map { $0[0] as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewDidDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear))
            .map { $0[0] as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var willMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.willMove))
            .map { $0[0] as? UIViewController }
      return ControlEvent(events: source)
    }
    
    var didMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.didMove))
            .map { $0[0] as? UIViewController }
        return ControlEvent(events: source)
    }
    
    /// Rx observable, triggered when the ViewController is being dismissed
    var isDismissing: ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.dismiss))
            .map { $0[0] as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
}
