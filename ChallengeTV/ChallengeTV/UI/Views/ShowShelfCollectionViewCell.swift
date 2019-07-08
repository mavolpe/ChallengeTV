//
//  ShowShelfCollectionViewCell.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

protocol ShowShelfCollectionViewCellDelegate : AnyObject {
    func getFilter()->String
    func showDetails(event:TVEvent)
}

class ShowShelfCollectionViewCell: UICollectionViewCell {

    @IBOutlet var showCollectionView: UICollectionView!
    
    weak var delegate:ShowShelfCollectionViewCellDelegate? = nil
    
    private var eventList:[TVEvent] = []
    
    private var eventListFiltered:[TVEvent]{
        get{
            if let filter = delegate?.getFilter(){
                if filter.isEmpty == false{
                    return eventList.filter({ (event) -> Bool in
                        
                        let containsName = event.name.lowercased().contains(filter)
                        var containsNetwork = false
                        if let network = event.show?.network?.name{
                            containsNetwork = network.lowercased().contains(filter)
                        }
                        
                        return containsName || containsNetwork
                    })
                }
            }
            return eventList
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showCollectionView.register(UINib(nibName: "ShowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: String(describing: ShowCollectionViewCell.self))
        
        NotificationCenter.default.addObserver(self, selector: #selector(filterChanged(_:)), name: HomeViewController.searchChangedNotificationName, object: nil)
    }
    
    @objc func filterChanged(_ notification:Notification){
        showCollectionView.contentOffset = CGPoint.zero
        showCollectionView.reloadData()
    }
    
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
        
        return eventListFiltered.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let showCollectionViewCell = showCollectionView.dequeueReusableCell(withReuseIdentifier: "ShowCollectionViewCell", for: indexPath) as? ShowCollectionViewCell{
            let event = eventListFiltered[indexPath.item]
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = eventListFiltered[indexPath.item]
        delegate?.showDetails(event: event)
    }
}
