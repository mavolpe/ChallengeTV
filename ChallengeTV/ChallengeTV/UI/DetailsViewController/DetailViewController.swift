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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let event = self.event{
            populateView(event: event)
        }
    }
    
    func populateView(event:TVEvent){
        
    }
}
