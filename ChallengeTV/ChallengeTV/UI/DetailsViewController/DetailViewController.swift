//
//  DetailViewController.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-08.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    public var event:TVEvent? = nil
    // image constraints
    @IBOutlet var centeredImageConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewSpaceToTop: NSLayoutConstraint!
    var imageToTheLeftTemp:NSLayoutConstraint? = nil
    var originalImageTopSpace:CGFloat = 0.0
    
    // details view constraints
    @IBOutlet var detailsCentered: NSLayoutConstraint!
    @IBOutlet var detailsHeightRatio: NSLayoutConstraint!
    @IBOutlet var detailsWidthEqualToSuper: NSLayoutConstraint!
    @IBOutlet var detailsTopToThumbnail: NSLayoutConstraint!
    
    // details view runtime constraints...
    var detailsLeftToImageRight:NSLayoutConstraint? = nil
    var detailsRightToButtonLeft:NSLayoutConstraint? = nil
    var detailsTopToSuperTop:NSLayoutConstraint? = nil
    var detailsHeightEqualToImageView:NSLayoutConstraint? = nil
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var thumbNail: UIImageView!
    @IBOutlet var detailsView: UIView!
    
    @IBOutlet var detailsHeading: UILabel!
    
    @IBOutlet var detailsSecondHeading: UILabel!
    @IBOutlet var thirdHeading: UILabel!
    @IBOutlet var fourthHeading: UILabel!
    @IBOutlet var fithHeading: UILabel!
    @IBOutlet var sixthHeading: UILabel!
    //@IBOutlet var summary: UITextView!
    @IBOutlet var summary:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createRuntimeLandscapeConstraints()

        if let event = self.event{
            populateView(event: event)
        }
        
        handleRotation()
    }
    
    func populateView(event:TVEvent){
        thumbNail.sd_setImage(with: event.thumbnailUrl) { (image, error, type, url) in
            
        }
        
        var heading = ""

        
        if event.networkInfo.isEmpty == false{
            detailsSecondHeading.text = String("\(event.showTitle) - \(event.networkInfo)")
        }else{
            detailsSecondHeading.text = event.showTitle
        }

        if event.episodeInfo.isEmpty == false{
            heading = event.episodeInfo
            heading += " " + event.name
        }else{
            heading = event.name
        }

        detailsHeading.text = heading
        
        thirdHeading.text = event.airingInfo
        
        fourthHeading.text = event.durationString
        
        fithHeading.text = event.genreDisplay
        
        sixthHeading.text = event.originalAirDate
        
        summary.text = event.detailSummary
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        handleRotation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        view.setNeedsUpdateConstraints()
    }
}

// MARK: Constraint management
extension DetailViewController{
    func createRuntimeLandscapeConstraints(){
        // for the thumbnail
        if imageToTheLeftTemp == nil{
            imageToTheLeftTemp = thumbNail.leftAnchor.constraint(
                equalTo: view.leftAnchor
            )
        }
        
        // for the details view
        if detailsLeftToImageRight == nil{
            detailsLeftToImageRight = detailsView.leftAnchor.constraint(
                equalTo: thumbNail.rightAnchor
            )
        }
        
        if detailsRightToButtonLeft == nil{
            detailsRightToButtonLeft = detailsView.rightAnchor.constraint(
                equalTo: closeButton.leftAnchor
            )
        }
        
        if detailsTopToSuperTop == nil{
            detailsTopToSuperTop = detailsView.topAnchor.constraint(
                equalTo: view.topAnchor
            )
        }
        
        if detailsHeightEqualToImageView == nil{
            detailsHeightEqualToImageView = detailsView.heightAnchor.constraint(
                equalTo: thumbNail.heightAnchor
            )
        }
    }
    
    func set(landscapeMode:Bool){

        if landscapeMode{
            set(portraitMode: false)
        }
        // true for landscape
        imageToTheLeftTemp?.isActive = landscapeMode
        detailsLeftToImageRight?.isActive = landscapeMode
        detailsRightToButtonLeft?.isActive = landscapeMode
        detailsTopToSuperTop?.isActive = landscapeMode
        detailsHeightEqualToImageView?.isActive = landscapeMode
        
        if !landscapeMode{
            set(portraitMode: true)
        }
    }
    
    func set(portraitMode:Bool){
        detailsHeightRatio.isActive = portraitMode
        detailsTopToThumbnail.isActive = portraitMode
        detailsWidthEqualToSuper.isActive = portraitMode
        detailsCentered.isActive = portraitMode
        centeredImageConstraint.isActive = portraitMode
    }
    
    func handleRotation(){
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight{
            // if we're in landscape mode...
            // move the thumbnail to the top - save the original location
            originalImageTopSpace = imageViewSpaceToTop.constant
            imageViewSpaceToTop.constant = 0
            set(landscapeMode: true)
        }else{
            imageViewSpaceToTop.constant = originalImageTopSpace
            set(landscapeMode: false)

        }
        self.view.updateConstraints()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
}
