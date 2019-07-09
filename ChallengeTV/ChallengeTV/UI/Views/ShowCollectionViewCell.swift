//
//  ShowCollectionViewCell.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit
import SDWebImage

class ShowCollectionViewCell: UICollectionViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var thumbNail: UIImageView!
    @IBOutlet var networkLabel: UILabel!
    
    @IBOutlet var highlightView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let tapGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ShowCollectionViewCell.thumbnailTapped(tapGesture:)))
//        tapGesture.cancelsTouchesInView = false
//        tapGesture.minimumPressDuration = 0.001
//        self.addGestureRecognizer(tapGesture)
    }
    
    private func highlightCell(highlight:Bool){
        highlightView.alpha = highlight ? 0.5 : 0
    }
    
    @objc private func thumbnailTapped(tapGesture:UILongPressGestureRecognizer){
        switch tapGesture.state{
        case .possible:
            highlightCell(highlight: false)
        case .began:
            highlightCell(highlight: true)
        case .changed:
            break
        case .ended:
            highlightCell(highlight: false)
        case .cancelled:
            highlightCell(highlight: false)
        case .failed:
            highlightCell(highlight: false)
        @unknown default:
            highlightCell(highlight: false)
        }
    }
    
    var event : TVEvent!{
        didSet{
            titleLabel.text = event.name
            startTimeLabel.text = event.airingString
            networkLabel.text = event.show?.network?.name
            
            if let url = event.thumbnailUrl{
                thumbNail.sd_setImage(with: url) { (image, error, cacheType, url) in
                    
                }
            }
        }
    }

}

//extension ShowCollectionViewCell : UIGestureRecognizerDelegate{
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}
