//
//  TVEvent.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

struct TVEvent: Decodable {
    let eventId:Int
    let name:String
    let startDate:Date
    
    let url:String?
    let season:Int?
    let number:Int?
    let airdate:String?
    let airtime:String?
    let runtime:Int?
    //let image:String?
    let summary:String?
    let show:Show?
    
    private enum CodingKeys: String, CodingKey {
        case eventId = "id"
        case name
        case startDate = "airstamp"
        case url
        case season
        case number
        case airdate
        case airtime
        case runtime
        //let image:String?
        case summary
        case show
    }
}

struct Show: Decodable {
    let id:Int
    let url:String?
    let name:String?
    let type:String?
    let language:String?
    let genres: [String]?
    let status:String?
    let runtime:Int?
    let premiered:String?
    let officialSite:String?
    let schedule:ShowSchedule?
    let rating: Rating?
    let weight: Int?
    let network:Network?
    let image: Image?
    let summary: String?
}

struct ShowSchedule :Decodable {
    let time:String?
    let days: [String]?
}

struct Rating: Decodable{
    let average: Double?
}

struct Network: Decodable{
    let id:Int
    let name:String?
    let country:Country?
}

struct Country: Decodable{
    let name:String?
    let code:String?
    let timezone:String?
}

struct Image: Decodable {
    let medium: String?
    let original: String?
}

// MARK: some helpers 
extension TVEvent{
    
    // this will only be available if we have a runtime
    public var endDate:Date?{
        get{
            guard let runtime = runtime else{
                return nil
            }
            return startDate.addingTimeInterval(Double(runtime*60))
        }
    }
    
    public var airingString:String{
        get{
            if let startTime = airtime{
                var airingTime = startTime
                if let endDate = self.endDate{
                    airingTime += String("-\(DateFormatter.airingTime.string(from: endDate))")
                }
                return airingTime
            }
            return ""
        }
    }
    
    public var thumbnailUrl:URL?{
        get{
            if let url = show?.image?.medium{
                return URL(string: url)
            }else if let url = show?.image?.original{
                return URL(string: url)
            }
            return nil
        }
    }
    
    public var genreDisplay:String{
        get{
            if let genreArray = show?.genres{
                return genreArray.joined(separator: ",")
            }
            return ""
        }
    }
    
    public func detailSummary(with color:UIColor = UIColor.white, with font:UIFont = UIFont.systemFont(ofSize: 17))->(text:String, attributedText:NSMutableAttributedString?){
        // if we have the episodes summary
        // return that... if not return
        // the show's summary...
        var summaryText = ""
        if let episodeSummary = summary{
            summaryText = episodeSummary
        }else if let showSummary = show?.summary{
            summaryText = showSummary
        }
        
        if summaryText.isEmpty == false{
            if let attributedText = summaryText.attributedStringFromHtmlString(){
                
                attributedText.setFontFace(font: font, color: color)
                
                if let summaryStripped = summaryText.stripOutHtml(){
                    return (text:summaryStripped, attributedText:attributedText)
                }
            }
        }
        
        return (text:summaryText, attributedText:nil)
    }
    
    public var detailSummary:String{
        // if we have the episodes summary
        // return that... if not return
        // the show's summary...
        var summaryText = ""
        if let episodeSummary = summary{
            summaryText = episodeSummary
        }else if let showSummary = show?.summary{
            summaryText = showSummary
        }
        
        if summaryText.isEmpty == false{
            if let stripped = summaryText.stripOutHtml(){
                return stripped
            }
        }
        
        return summaryText
    }
    
    public var airingInfo:String{
        get{

            var airing = ""
            if airingString.isEmpty == false{
                airing = airingString
                if let airdate = airdate{
                    airing = airing + " " + airdate
                }
            }
            
            return airing
        }
    }
    
    public var originalAirDate:String{
        get{
            let airdateLabel = NSLocalizedString("Premiered:", comment:"Original airdate, or date originally shown")
            var airDateText = ""
            if let premiered = show?.premiered{
                airDateText = String("\(airdateLabel) \(premiered)")
            }
            return airDateText
        }
    }
    
    public var durationString:String{
        if let duration = self.runtime{
            let label = NSLocalizedString("mins", comment: "Minutes short form")
            return String("\(duration) \(label)")
        }
        return ""
    }
    
    public var episodeInfo:String{
        get{
            var info = ""
            if let eNumber = number{
                if let season = season{
                    info = String("S\(season):E\(eNumber)")
                }
            }
            return info
        }
    }
    
    public var showTitle:String{
        get{
            if let name = show?.name{
                return name
            }
            return ""
        }
    }
    
    public var networkInfo:String{
        get{
            if let network = show?.network?.name{
                return network
            }
            return ""
        }
    }
}

