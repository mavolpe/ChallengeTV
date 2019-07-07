//
//  CellSizeUtil.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-07.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class CellSizeUtil {
    
    static func getBottomSpaceRatio()->CGFloat{
        let ipad = UIDevice.current.userInterfaceIdiom == .pad
        
        let spaceRatio:CGFloat = ipad ? 3.5 : 1.8
        
        return spaceRatio
    }
    
    static func getCellWidth()->CGFloat{
        let ipad = UIDevice.current.userInterfaceIdiom == .pad
        
        let cellWidth:CGFloat = ipad ? 200 : 100
        
        return cellWidth
    }
    
    static func getShelfCellSize(bounds:CGRect)->CGSize{
        guard bounds.width > 0 && bounds.height > 0 else{
            return CGSize.zero
        }

        let showCellSize = CellSizeUtil.getShowCellSize(bounds: bounds)
        
        return CGSize(width: bounds.width, height: showCellSize.height)
    }
    
    static func getShowCellSize(bounds:CGRect)->CGSize{
        guard bounds.width > 0 && bounds.height > 0 else{
            return CGSize.zero
        }
        
        let cellWidth:CGFloat = CellSizeUtil.getCellWidth()
        
        // now we need to calculate the height of our poster...
        let posterHeight = cellWidth * 1.403
        
        // now we will use 1/3 of the poster height for the space at the bottom to accomodate text etc... as a starting point...
        var infoArea = posterHeight / CellSizeUtil.getBottomSpaceRatio()
        
        infoArea = max(infoArea, 60)
        
        let height:CGFloat = infoArea + posterHeight
        
        return CGSize(width: cellWidth, height: height)
    }
    
}
