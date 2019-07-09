//
//  Cast.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-09.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

struct Cast {
    let castMembers:[CastMember]?
}

struct CastMember : Decodable{
    let person:Person?
    let character:Character?
}

struct Person : Decodable {
    let id:Int
    let name:String
    let image:Image?
}

struct Character : Decodable {
    let id:Int
    let name:String
    let image:Image?
}

/*
{
    person: {
        id: 11024,
        url: "http://www.tvmaze.com/people/11024/stephanie-lemelin",
        name: "Stephanie Lemelin",
        country: {
            name: "United States",
            code: "US",
            timezone: "America/New_York"
        },
        birthday: "1979-06-29",
        deathday: null,
        gender: "Female",
        image: {
            medium: "http://static.tvmaze.com/uploads/images/medium_portrait/184/460999.jpg",
            original: "http://static.tvmaze.com/uploads/images/original_untouched/184/460999.jpg"
        },
        _links: {
            self: {
                href: "http://api.tvmaze.com/people/11024"
            }
        }
    },
    character: {
        id: 87274,
        url: "http://www.tvmaze.com/characters/87274/young-justice-tigress-artemis-crock",
        name: "Tigress / Artemis Crock",
        image: {
            medium: "http://static.tvmaze.com/uploads/images/medium_portrait/83/209811.jpg",
            original: "http://static.tvmaze.com/uploads/images/original_untouched/83/209811.jpg"
        },
        _links: {
            self: {
                href: "http://api.tvmaze.com/characters/87274"
            }
        }
    },
    self: false,
    voice: true
},
 */
