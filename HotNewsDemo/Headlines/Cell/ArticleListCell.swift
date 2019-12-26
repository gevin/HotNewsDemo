//
//  NewsListCell.swift
//  HotNewsDemo
//
//  Created by GevinChen on 2019/12/19.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ArticleListCell: UITableViewCell {

    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func cellWith( tableView: UITableView, indexPath: IndexPath ) -> Self {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: Self.self), for: indexPath) as! Self
        return cell
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
}
