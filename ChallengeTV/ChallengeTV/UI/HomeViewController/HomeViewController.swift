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
    
    @IBOutlet var searchBar: UISearchBar!
    let leftSectionInset:CGFloat = 10.0
    
    @IBOutlet var topBarTopConstraint: NSLayoutConstraint!
    var schedule:ScheduleCache = [:]
    
    var lastScrollY:CGFloat = 0.0

    @IBOutlet var topBarView: UIView!
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
        
        let searchTapDismiss:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(HomeViewController.dismissSearch(recognizer:)))
        self.view.addGestureRecognizer(searchTapDismiss)
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
        let height:CGFloat = section > 0 ? 50.0 : 100
        let cellWidth = width 
        return CGSize(width: cellWidth, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // the inner collectionview has to have the section insets - a bit off the size or we will get
        // a warning from the system at runtime
        var boundsMinusInsets = collectionView.bounds
        var width = boundsMinusInsets.size.width
        width = width - leftSectionInset - 5
        boundsMinusInsets.size.width = width
        return CellSizeUtil.getShelfCellSize(bounds: boundsMinusInsets)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: leftSectionInset, bottom: 0, right: 0)
    }
}

// MARK: TableView delegates and search functionality
extension HomeViewController : UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchLower = searchText.lowercased()
        
//        searchedAirports = airports.filter({$0.city.lowercased().contains(searchLower) ||
//            $0.IATA.lowercased().contains(searchLower) ||
//            $0.country.lowercased().contains(searchLower) ||
//            $0.name.lowercased().contains(searchLower)
//        })
//        
//        searchResults.reloadData()
//        searchResults.isHidden = false
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        clearSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearSearch()
    }
    
    func clearSearch(){
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    @objc func dismissSearch(recognizer:UIGestureRecognizer){
        clearSearch()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder{
            clearSearch()
        }
        
        handleShowHideTopBar()
    }
    
    func handleShowHideTopBar(){
        let contentOffset = scheduleCollectionView.contentOffset
        if contentOffset.y > lastScrollY && contentOffset.y >= 0{
            // we're moving up...
            let hiddenHeight = topBarView.frame.size.height * -1.0
            if topBarTopConstraint.constant > hiddenHeight{
                var newTopBarY = topBarTopConstraint.constant - (contentOffset.y - lastScrollY)
                newTopBarY = max(newTopBarY, hiddenHeight)
                topBarTopConstraint.constant = newTopBarY
            }
        }else{
            // we're moving down... 
            if topBarTopConstraint.constant < 0{
                var newTopBarY = topBarTopConstraint.constant + (lastScrollY - contentOffset.y)
                newTopBarY = min(newTopBarY, 0)
                topBarTopConstraint.constant = newTopBarY
            }
        }
        if contentOffset.y >= 0{
            lastScrollY = contentOffset.y
        }
    }
}

