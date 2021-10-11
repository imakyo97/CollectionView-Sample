//
//  MyCollectionViewCell.swift
//  CollectionViewHorizontal-Sample
//
//  Created by 今村京平 on 2021/10/10.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var myLable: UILabel!

    func configure(text: String) {
        myLable.text = text
    }
}
