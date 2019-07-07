//
//  ViewController.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController{
    @IBOutlet var scheduleCollectionView: UICollectionView!
    
    
    var schedule:ScheduleCache = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register our cell
        scheduleCollectionView.register(UINib(nibName: "ShowShelfCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: String(describing: ShowShelfCollectionViewCell.self))
        
        ScheduleService.sharedInstance.fetchSchedule { 
            ScheduleService.sharedInstance.getScheduleCache(completion: { [weak self] (schedule) in
                guard let this = self else{
                    return
                }
                this.schedule = schedule
                this.scheduleCollectionView.reloadData()
            })
            
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = scheduleCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
        
        for cell in scheduleCollectionView.visibleCells{
            if let showShelf = cell as? ShowShelfCollectionViewCell{
                guard let flowLayout = showShelf.showCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                    return
                }
                flowLayout.invalidateLayout()
            }
        }
    }
}

extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return schedule.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let showShelfCollectionViewCell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "ShowShelfCollectionViewCell", for: indexPath) as? ShowShelfCollectionViewCell{
            
            if let schedule = schedule[indexPath.section]?.schedule{
                showShelfCollectionViewCell.schedule = schedule
            }
            return showShelfCollectionViewCell
        }
            
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let showShelfSectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ShowShelfSectionHeaderView", for: indexPath) as? ShowShelfSectionHeaderView{
            if let sectionDate = schedule[indexPath.section]?.date{
                showShelfSectionHeaderView.sectionLabel.text = DateFormatter.shelfDisplayFormatt.string(from: sectionDate)
            }
            return showShelfSectionHeaderView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = collectionView.bounds.width
        let height:CGFloat = 50.0
        let cellWidth = width // compute your cell width
        return CGSize(width: cellWidth, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height / 3
        let cellWidth = width // compute your cell width
        return CGSize(width: cellWidth, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
}

