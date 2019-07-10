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
    
    private func checkFilterCache(filter:String, section:Int)->[TVEvent]{
        if let sectionFilters = filterCache[section]{
            if let eventsForFilterAndSection = sectionFilters[filter]{
                return eventsForFilterAndSection
            }
        }
        return []
    }
    
    private func eventListFiltered(section:Int)->[TVEvent]{
        if let events = schedule[section]?.schedule.events{
            NSLog("####FILTERING for \(section) \(filter)")
            if filter.isEmpty == false{
                
                //if checkFilterCache(filter: filter, section: section)
                
                return events.filter({ (event) -> Bool in
                    
                    let containsName = event.name.lowercased().contains(filter)
                    let containsShowName = event.showTitle.lowercased().contains(filter)
                    var containsNetwork = false
                    if let network = event.show?.network?.name{
                        containsNetwork = network.lowercased().contains(filter)
                    }
                    
                    return containsName || containsNetwork || containsShowName
                })
            }
            return events
        }
        return [] // we don't have anything for this section yet... return nothing...
    }
    
    var lastScrollY:CGFloat = 0.0
    
    var isDecelerating = false
    
    var filter:String = ""
    var filterCache:[Int:[String:[TVEvent]]] = [:]
    
    public static let searchChangedNotificationName = Notification.Name("searchChangedNotificationName")

    @IBOutlet var topBarView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register our cell
        scheduleCollectionView.register(UINib(nibName: "ShowShelfCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: String(describing: ShowShelfCollectionViewCell.self))
        
        TVService.sharedInstance.fetchSchedule { 
            TVService.sharedInstance.getScheduleCache(completion: { [weak self] (schedule) in
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.scheduleCollectionView{
            return 1
        }
        
        // the tag contains our section
        return eventListFiltered(section: collectionView.tag).count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.scheduleCollectionView{
            return schedule.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.scheduleCollectionView{
            if let showShelfCollectionViewCell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "ShowShelfCollectionViewCell", for: indexPath) as? ShowShelfCollectionViewCell{
                
//                if let schedule = schedule[indexPath.section]?.schedule{
//                    showShelfCollectionViewCell.schedule = schedule
//                }
                showShelfCollectionViewCell.delegate = self
                showShelfCollectionViewCell.showCollectionView.tag = indexPath.section
                showShelfCollectionViewCell.showCollectionView.delegate = self
                showShelfCollectionViewCell.showCollectionView.dataSource = self
                showShelfCollectionViewCell.showCollectionView.reloadData()
                return showShelfCollectionViewCell
            }
        }
        
        if let showCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCollectionViewCell", for: indexPath) as? ShowCollectionViewCell{
            // the tag contains our section
            let event = eventListFiltered(section: collectionView.tag)[indexPath.item]
            showCollectionViewCell.event = event
            return showCollectionViewCell
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
        return eventListFiltered(section: section).count > 0
    }
    
//    func sectionHasDataWithFilter(section:Int)->Bool{
//        //return true
//        if  let eventList = schedule[section]?.schedule.events{
//            if eventList.filter({ (event) -> Bool in
//
//                let containsName = event.name.lowercased().contains(filter)
//                let containsShowName = event.showTitle.lowercased().contains(filter)
//                var containsNetwork = false
//                if let network = event.show?.network?.name{
//                    containsNetwork = network.lowercased().contains(filter)
//                }
//
//                return containsName || containsNetwork || containsShowName
//            }).count == 0{
//                return false
//            }
//        }
//
//        return true
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView == self.scheduleCollectionView{
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
        
        // else we are detail with a shelf's collection view...
        return CGSize.zero
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.scheduleCollectionView{
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
        
//        if filter.isEmpty == false{
//            var smallBounds = collectionView.bounds
//            smallBounds.size.height = 1
//            if sectionHasDataWithFilter(section: collectionView.tag) == false{
//                return CellSizeUtil.getShowCellSize(bounds: collectionView.bounds)
//            }
//        }
        
        // else we are detail with a shelf's collection view...
        return CellSizeUtil.getShowCellSize(bounds: collectionView.bounds)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == scheduleCollectionView{
            return UIEdgeInsets(top: 0, left: leftSectionInset, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != scheduleCollectionView{
            // the tag contains our section
            let event = eventListFiltered(section: collectionView.tag)[indexPath.item]
            showDetails(event: event)
        }
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
        
        scheduleCollectionView.reloadData()

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
        if scrollView == self.scheduleCollectionView{
            if searchBar.isFirstResponder && !isDecelerating{
                clearSearch()
            }
            
            handleShowHideTopBar()
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scheduleCollectionView{
            isDecelerating = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scheduleCollectionView{
            isDecelerating = false
        }
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

