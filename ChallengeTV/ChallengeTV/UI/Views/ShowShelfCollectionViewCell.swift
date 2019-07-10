//
//  ShowShelfCollectionViewCell.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//
// Using protocol composition and sticking to MVC by using the VC as the datasource
// and delegate came from
// https://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell-in-swift/

import UIKit

class ShowShelfCollectionViewCell: UICollectionViewCell {

    @IBOutlet var showCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showCollectionView.register(UINib(nibName: "ShowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: String(describing: ShowCollectionViewCell.self))
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        showCollectionView.delegate = dataSourceDelegate
        showCollectionView.dataSource = dataSourceDelegate
        showCollectionView.tag = row
        showCollectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        get {
            return showCollectionView.contentOffset.x
        }
        
        set {
            showCollectionView.contentOffset.x = newValue
        }
    }
}
