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

    public var viewDidLoad: ControlEvent<Void> {
      let source = self.methodInvoked(#selector(Base.viewDidLoad))
        .map { _ in }
      return ControlEvent(events: source)
    }

    public var viewWillAppear: ControlEvent<Bool> {
      let source = self.methodInvoked(#selector(Base.viewWillAppear))
        .map { $0[0] as? Bool ?? false }
      return ControlEvent(events: source)
    }
    
    public var viewDidAppear: ControlEvent<Bool> {
      let source = self.methodInvoked(#selector(Base.viewDidAppear))
        .map { $0[0] as? Bool ?? false }
      return ControlEvent(events: source)
    }
    
    public var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear))
            .map { $0[0] as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    public var viewDidDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear))
            .map { $0[0] as? Bool ?? false }
        return ControlEvent(events: source)
    }

    public var willMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.willMove))
            .map { $0[0] as? UIViewController }
      return ControlEvent(events: source)
    }
    
    public var didMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.didMove))
            .map { $0[0] as? UIViewController }
        return ControlEvent(events: source)
    }
    
    /// Rx observable, triggered when the ViewController is being dismissed
    public var isDismissing: ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.dismiss))
            .map { $0[0] as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
}
