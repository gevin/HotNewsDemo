//
//  ImageInteractor.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/26.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import SDWebImage

enum ImageState {
    case none
    case completed(_ image: UIImage? )
    case loading
    case error(_ error: Error? )
}

protocol ImageInteractorType {
    
    func getImage( urlString: String ) -> Observable<ImageState>
    
}

class ImageInteractor: ImageInteractorType {
    
    var apiService: APIServiceType
    
    var realmService: RealmServiceType
    
    var downloadTaskDict:[String:Observable<ImageState>] = [:]
    
    init( apiService: APIServiceType, realmService: RealmServiceType) {
        self.apiService = apiService
        self.realmService = realmService
    }
    
    func getImage( urlString: String ) -> Observable<ImageState> {
        
        guard let url = URL(string: urlString) else { return Observable.of(ImageState.completed(nil))}
        
        // downloading
        if let runningTask = downloadTaskDict[urlString] {
            return runningTask
        }
        
        if let image = SDImageCache.shared.imageFromMemoryCache(forKey: urlString) {
            return Observable.of(ImageState.completed(image))
        }
        
        if let image = SDImageCache.shared.imageFromDiskCache(forKey: urlString) {
            SDImageCache.shared.storeImage(toMemory: image, forKey: urlString)
            return Observable.of(ImageState.completed(image))
        }
        
        let downloadImageTask = self.apiService.downloadImage(url: url)
            .do(onNext: {[weak self] (state:ImageState) in
                guard let strongSelf = self else {return}
                if case let ImageState.completed(imageOrNil) = state {
                    if let image = imageOrNil {
                        SDImageCache.shared.storeImage(toMemory: image, forKey: urlString)
                        SDImageCache.shared.storeImageData(toDisk: image.sd_imageData(), forKey: urlString)
                    }
                    strongSelf.downloadTaskDict[urlString] = nil
                }
            })
            .share(replay: 1)
        
        downloadTaskDict[urlString] = downloadImageTask
        return downloadImageTask
    }
}


extension UIImageView {
    
    // MARK: - loading
    
    struct AssociatedKeys {
        static var isLoadingKey: UInt8 = 0
        static var loadingViewKey: UInt8 = 0
    }
    
    var isLoading: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.isLoadingKey) as? Bool else { return false }
            return value
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isLoadingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue {
                self.loadingView.isHidden = false
                self.loadingView.startAnimating()
            } else {
                self.loadingView.isHidden = true
                self.loadingView.stopAnimating()
            }
        }
    }
    
    var loadingView: UIActivityIndicatorView {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.loadingViewKey) as? UIActivityIndicatorView {
                return value
            } else {
                let view = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
                objc_setAssociatedObject(self, &AssociatedKeys.loadingViewKey, view, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
                self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
                view.isHidden = true
                view.stopAnimating()
                return view
            }
        }
        set {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.loadingViewKey) as? UIActivityIndicatorView {
                value.stopAnimating()
                value.removeFromSuperview()
            }
            
            objc_setAssociatedObject(self, &AssociatedKeys.loadingViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.addSubview(newValue)
            newValue.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraint(NSLayoutConstraint(item: newValue, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: newValue, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
            newValue.isHidden = true
            newValue.stopAnimating()
        }
    }
    
    func setState(_ state: ImageState ) {
        switch state {
        case .completed(image: let image ):
            self.image = image
            self.isLoading = false
        case .loading:
            self.isLoading = true
        case .error(error: _):
            break
        case .none:
            self.isLoading = false
        }
    }
    
}

extension Reactive where Base: UIImageView {

    var state: Binder<ImageState> {
        return Binder(self.base) { control, value in
            control.setState(value)
        }
    }
    
}
