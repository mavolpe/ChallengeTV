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
    
    
//    let url:String?
//        season: 1,
//        number: 26,
//        airdate: "2014-12-01",
//        airtime: "07:30",
//        runtime: 11,
//        image: null,
//        summary: "",
    
    private enum CodingKeys: String, CodingKey {
        case eventId = "id"
        case name
        case startDate = "airstamp"
    }
    
    
    
//    id: 339141,
//    url: "http://www.tvmaze.com/episodes/339141/clarence-1x26-rough-riders-elementary",
//    name: "Rough Riders Elementary",
//    season: 1,
//    number: 26,
//    airdate: "2014-12-01",
//    airtime: "07:30",
//    airstamp: "2014-12-01T12:30:00+00:00",
//    runtime: 11,
//    image: null,
//    summary: "",
}
