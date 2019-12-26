//
//  NewsDetailViewController.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/25.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewsDetailViewController: UIViewController, ViewType {
    
    var viewModel: NewsDetailViewModelType?
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsAuthorLabel: UILabel!
    @IBOutlet weak var newsContentLabel: UILabel!
    @IBOutlet weak var newContentTextView: UITextView!
    
    deinit {
        print("NewsDetailViewController dealloc")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindUI()
        self.viewModel?.initial()
    }
    
    func bindUI() {
        self.viewModel?.newsImage.drive(self.newsImage.rx.state).disposed(by: disposeBag)
        self.viewModel?.newsTitle.drive(self.newsTitleLabel.rx.text).disposed(by: disposeBag)
        self.viewModel?.newsAuthor.drive(self.newsAuthorLabel.rx.text).disposed(by: disposeBag)
        self.viewModel?.newsContent.drive(self.newsContentLabel.rx.text).disposed(by: disposeBag)
    }
    
    @IBAction func testChangeClicked(_ sender: Any) {
        self.viewModel?.changeContent("修改數值測試")
    }

}
