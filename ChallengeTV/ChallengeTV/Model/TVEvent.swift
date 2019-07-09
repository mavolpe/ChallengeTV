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
        if let genreArray = show?.genres{
            return genreArray.joined(separator: ",")
        }
        return ""
    }
    
    public var detailSummary:String{
        // if we have the episodes summary
        // return that... if not return
        // the show's summary...
        if let episodeSummary = summary{
            return episodeSummary
        }else if let showSummary = show?.summary{
            return showSummary
        }
        return ""
    }
    
    public var airingInfo:String{
        let onAt = NSLocalizedString("Airing:", comment:"Word should mean airing - or being showed at")
        let premiered = NSLocalizedString("Premiered:", comment:"Original airdate, or date originally shown")
        
        var airing = ""
        if airingString.isEmpty == false{
            airing = String("\(onAt) \(airingString)")
            if let airdate = airdate{
                airing = airing + " " + airdate
            }
        }
        if let premiered = show?.premiered{
            airing = String("\(airing) - \(premiered)")
        }
        
        return airing
    }
}

