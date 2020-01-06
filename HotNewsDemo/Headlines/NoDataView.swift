//
//  NoDataView.swift
//  MovieListDemo
//
//  Created by GevinChen on 2020/1/1.
//  Copyright © 2020 GevinChen. All rights reserved.
//

import UIKit

class NoDataView: UIView {

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    static func create() -> NoDataView {
        let nib = UINib(nibName: "NoDataView", bundle: Bundle.main)
        let array = nib.instantiate(withOwner: nil, options: nil)
        return array[0] as! NoDataView
    }

}
