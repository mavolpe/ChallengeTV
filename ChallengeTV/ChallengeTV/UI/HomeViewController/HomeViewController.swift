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
    
    var isDecelerating = false
    
    var filter:String = ""
    
    public static let searchChangedNotificationName = Notification.Name("searchChangedNotificationName")

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
        searchTapDismiss.cancelsTouchesInView = false
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
    
    @IBAction func unwindToHomeView(sender: UIStoryboardSegue)
    {
        NSLog("")
        //let sourceViewController = sender.source
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? DetailViewController{
            if let event = sender as? TVEvent{
                detailVC.event = event
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
            showShelfCollectionViewCell.delegate = self
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
    
    func sectionHasDataWithFilter(section:Int)->Bool{
        if  let eventList = schedule[section]?.schedule.events{
            if eventList.filter({ (event) -> Bool in
                
                let containsName = event.name.lowercased().contains(filter)
                var containsNetwork = false
                if let network = event.show?.network?.name{
                    containsNetwork = network.lowercased().contains(filter)
                }
                
                return containsName || containsNetwork
            }).count == 0{
                return false
            }
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if filter.isEmpty == false{
            if sectionHasDataWithFilter(section: section) == false{
                return CGSize(width: collectionView.bounds.width, height: 1)
            }
        }
        
        let width = collectionView.bounds.width
        let height:CGFloat = section > 0 ? 50.0 : 100
        let cellWidth = width 
        return CGSize(width: cellWidth, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if filter.isEmpty == false{
            if sectionHasDataWithFilter(section: indexPath.section) == false{
                return CGSize(width: collectionView.bounds.width, height: 1)
            }
        }

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

// MARK: Search bar and top bar handling...
extension HomeViewController : UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, ShowShelfCollectionViewCellDelegate{
    func showDetails(event: TVEvent) {
        performSegue(withIdentifier: "presentShowDetails", sender: event)
    }
    
    func getFilter() -> String {
        return filter
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filter = searchText.lowercased()
        
        if let flowLayout = scheduleCollectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            flowLayout.invalidateLayout()
        }
        
        NotificationCenter.default.post(name: HomeViewController.searchChangedNotificationName, object: filter)

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
        //searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    @objc func dismissSearch(recognizer:UIGestureRecognizer){
        clearSearch()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder && !isDecelerating{
            clearSearch()
        }
        
        handleShowHideTopBar()
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isDecelerating = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDecelerating = false
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

