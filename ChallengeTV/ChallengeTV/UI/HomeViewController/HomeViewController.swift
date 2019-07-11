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
    @IBOutlet var topBarTopConstraint: NSLayoutConstraint!
    @IBOutlet var topBarView: UIView!
    
    private var schedule:ScheduleList = []
    private var filtered:ScheduleList = []
    private let leftSectionInset:CGFloat = 10.0
    private var lastScrollY:CGFloat = 0.0
    private var isDecelerating = false
    private var filter:String = ""
    private var errorShowing:Bool = false

    private var storedOffsets = [Int: CGFloat]()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register our cell
        scheduleCollectionView.register(UINib(nibName: "ShowShelfCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: String(describing: ShowShelfCollectionViewCell.self))
        TVService.sharedInstance.attachObserver(observer: self)
        TVService.sharedInstance.fetchSchedule()
        
        let searchTapDismiss:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(HomeViewController.dismissSearch(recognizer:)))
        searchTapDismiss.cancelsTouchesInView = false
        self.view.addGestureRecognizer(searchTapDismiss)
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
    
    // MARK: Segue management
    @IBAction func unwindToHomeView(sender: UIStoryboardSegue)
    {

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? DetailViewController{
            if let event = sender as? TVEvent{
                detailVC.event = event
            }
        }
    }
    
    // MARK: Styling
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Error message presentation
    private func showErrorMessage(message:String){
        guard errorShowing == false && self.view.window != nil else{
            return
        }
        errorShowing = true
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] action in
            self?.errorShowing = false
        }))
        
        self.present(alert, animated: true)
    }
}

extension HomeViewController : TVServiceObserver{
    
    func errorEncountered(error: ChallengeTVErrorProtocol?) {
        if let error = error{
            showErrorMessage(message: error.localizedDescription)
        }
    }
    
    func scheduleUpdated() {
        TVService.sharedInstance.getScheduleList(completion: { [weak self] (schedule) in
            guard let this = self else{
                return
            }
            this.schedule = schedule
            this.scheduleCollectionView.reloadData()
        })
    }
}

// MARK: Collection view delegates
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
            return scheduleFiltered.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.scheduleCollectionView{
            if let showShelfCollectionViewCell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "ShowShelfCollectionViewCell", for: indexPath) as? ShowShelfCollectionViewCell{

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
            let sectionDate = scheduleFiltered[indexPath.section].date
            showShelfSectionHeaderView.sectionLabel.text = DateFormatter.shelfDisplayFormatt.string(from: sectionDate)

            return showShelfSectionHeaderView
        }
        
        return UICollectionReusableView()
    }
    
    func sectionHasDataWithFilter(section:Int)->Bool{
        return eventListFiltered(section: section).count > 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView == self.scheduleCollectionView{
            
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

            // the inner collectionview has to have the section insets - a bit off the size or we will get
            // a warning from the system at runtime
            var boundsMinusInsets = collectionView.bounds
            var width = boundsMinusInsets.size.width
            width = width - leftSectionInset - 5
            boundsMinusInsets.size.width = width
            return CellSizeUtil.getShelfCellSize(bounds: boundsMinusInsets)
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let collectionViewCell = cell as? ShowShelfCollectionViewCell else { return }
        
        // we pass the section not the row - because we divide days by sections...
        collectionViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        
        collectionViewCell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let collectionViewCell = cell as? ShowShelfCollectionViewCell else { return }
        
        storedOffsets[indexPath.section] = collectionViewCell.collectionViewOffset
    }
}

// MARK: Search bar and top bar handling...
extension HomeViewController : UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate{
    func showDetails(event: TVEvent) {
        performSegue(withIdentifier: "presentShowDetails", sender: event)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filter = searchText.lowercased()
        
        // produce a filtered schedule here...
        filtered = filterSchedule
        
        // cleared stored offsets because they are no longer relevant
        storedOffsets = [:]
        
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

// MARK: filtering functions and computed properties...
extension HomeViewController{
    // a convenience function that handles optional chaining to clean up code
    private func eventListFiltered(section:Int)->[TVEvent]{
        if let events = scheduleFiltered[section].schedule.events{
            return events
        }
        return [] // we don't have anything for this section yet... return nothing...
    }
    
    // our filtered schedule - only when the filter is on... otherwise the full schedule
    private var scheduleFiltered:ScheduleList{
        get{
            guard filter.isEmpty == false else{
                return schedule
            }
            return filtered
        }
    }
    
    // a property that can be used to produce a filtered schedule...
    private var filterSchedule:ScheduleList{
        get{
            guard filter.isEmpty == false else{
                return schedule
            }
            return schedule.filter(filter: filter)
        }
    }
}

