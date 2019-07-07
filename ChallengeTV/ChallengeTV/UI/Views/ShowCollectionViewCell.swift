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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var event : TVEvent!{
        didSet{
            titleLabel.text = event.name
            startTimeLabel.text = event.airtime
            networkLabel.text = event.show?.network?.name
            
            if let url = event.show?.image?.medium{
                thumbNail.sd_setImage(with: URL(string: url)) { (image, error, cacheType, url) in
                    
                }
            }else if let url = event.show?.image?.original{
                thumbNail.sd_setImage(with: URL(string: url)) { (image, error, cacheType, url) in
                    
                }
            }
        }
    }

}
