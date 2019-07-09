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

extension CastMember{
    public var personThumbnailUrl:URL?{
        get{
            if let url = person?.image?.medium{
                return URL(string: url)
            }else if let url = person?.image?.original{
                return URL(string: url)
            }
            return nil
        }
    }
    
    public var personName:String{
        get{
            if let name = person?.name{
                return name
            }
            return ""
        }
    }
    public var characterName:String{
        get{
            if let name = character?.name{
                return name
            }
            return ""
        }
    }
}
