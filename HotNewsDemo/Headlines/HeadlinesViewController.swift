//
//  ViewController.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/19.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SVProgressHUD
import SDWebImage
import Moya
import Alamofire
import Realm
import RealmSwift


struct HeadlinesSectionModel {
    var header: String
    var items:[ArticleListViewModel]
}

extension HeadlinesSectionModel: AnimatableSectionModelType {
    typealias Item = ArticleListViewModel
    typealias Identity = String
    
    var identity: String {
        return header
    }

    init(original: HeadlinesSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

class HeadlinesViewController: UIViewController, ViewType {
    
    var viewModel: HeadlinesViewModelType?
    var disposeBag = DisposeBag()
    var sectionRelay = BehaviorRelay<[HeadlinesSectionModel]>( value: [HeadlinesSectionModel(header: "", items: [])] )

    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl = UIRefreshControl(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewConfigure()
        self.bindUI()
        self.viewModel?.initial()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // view 與 viewModel bind
    func bindUI() {
        // article model list bind to section relay
        self.viewModel?.articleList
            .drive(onNext: {[weak self] (articleVMs:[ArticleListViewModel]) in
                guard let strongSelf = self else {return}
                var sections = strongSelf.sectionRelay.value
                if sections.count == 0 {
                    sections.append( HeadlinesSectionModel(header: "", items: []) )
                }
                sections[0].items = articleVMs
                strongSelf.sectionRelay.accept(sections)
            })
            .disposed(by: disposeBag)
        
        self.viewModel?.loading
            .drive(onNext: { (isLoading:Bool) in
                if isLoading {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
                }
            })
            .disposed(by: disposeBag)
        
        self.viewModel?.error
            .drive(onNext: { (error:Error) in
                print(error)
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    // 設定 tableView
    func tableViewConfigure() {
        // assign delegate 
        self.tableView.delegate = self
        
        // pulldown to refresh 
        if #available( iOS 10.0, *) {
            self.tableView.refreshControl = self.refreshControl
            let refresh_size = self.tableView.refreshControl?.bounds.size
            self.tableView.refreshControl?.bounds = CGRect(x: 0, y: 0, width: refresh_size?.width ?? 0, height: refresh_size?.height ?? 0)
        } else {
            self.tableView.addSubview(refreshControl)
            let refresh_bounds = CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width , height: 44 )
            refreshControl.bounds = refresh_bounds
        }
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh")
        refreshControl
            .rx
            .controlEvent(.valueChanged)
            .asObservable()
            .subscribe {[weak self] (_) in
                guard let strongSelf = self else {return}
                strongSelf.refreshControl.endRefreshing()
                strongSelf.viewModel?.refresh()
            }.disposed(by: self.disposeBag)
        
        // register cell
        self.tableView.register(UINib(nibName: "ArticleListCell", bundle: nil), forCellReuseIdentifier: "ArticleListCell")
        
        // config cell
        let dataSource = RxTableViewSectionedAnimatedDataSource<HeadlinesSectionModel>(configureCell: { (_, tableView, indexPath, model: ArticleListViewModel ) -> UITableViewCell in
            let cell = ArticleListCell.cellWith(tableView: tableView, indexPath: indexPath)
            model.content
                .bind(to: cell.contentLabel.rx.text )
                .disposed(by: cell.disposeBag)
            model.image
                .bind(to: cell.newsImageView.rx.state)
                .disposed(by: cell.disposeBag)
            return cell
        })
        self.sectionRelay.bind(to: self.tableView.rx.items(dataSource: dataSource) ).disposed(by: disposeBag)
    }
    
}

extension HeadlinesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sections = self.sectionRelay.value
        let articleModel = sections[indexPath.section].items[indexPath.row]
        self.viewModel?.selectArticle(articleVM: articleModel)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}




