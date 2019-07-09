//
//  CastMemberCellCollectionViewCell.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-09.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class CastMemberCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var thumbNail: UIImageView!
    @IBOutlet var character: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var castMember:CastMember!{
        didSet{
            if castMember.characterName.isEmpty == false{
                character.text = String("As \(castMember.characterName)")
            }
            
            titleLabel.text = castMember.personName
            
            if let url = castMember.personThumbnailUrl{
                thumbNail.sd_setImage(with: url) { (image, error, type, url) in
                    
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbNail.image = nil
    }
}
