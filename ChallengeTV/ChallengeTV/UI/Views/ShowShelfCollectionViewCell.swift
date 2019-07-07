//
//  ShowShelfCollectionViewCell.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class ShowShelfCollectionViewCell: UICollectionViewCell {

    @IBOutlet var showCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showCollectionView.register(UINib(nibName: "ShowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: String(describing: ShowCollectionViewCell.self))

    }
    
    private var eventList:[TVEvent] = []
    
    public var schedule:Schedule!{
        didSet{
            if let events = schedule.events{
                eventList = events
                showCollectionView.reloadData()
            }
        }
    }
}

extension ShowShelfCollectionViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let showCollectionViewCell = showCollectionView.dequeueReusableCell(withReuseIdentifier: "ShowCollectionViewCell", for: indexPath) as? ShowCollectionViewCell{
            let event = eventList[indexPath.item]
            showCollectionViewCell.event = event
            return showCollectionViewCell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CellSizeUtil.getShowCellSize(bounds: collectionView.bounds)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.5
    }
    
}
