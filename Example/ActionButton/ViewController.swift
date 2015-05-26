//
//  ViewController.swift
//  ActionButton
//
//  Created by Lourenço Marinho on 05/25/2015.
//  Copyright (c) 05/25/2015 Lourenço Marinho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var actionButton: ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let twitterImage = UIImage(named: "twitter_icon.png")!
        let plusImage = UIImage(named: "googleplus_icon.png")!
        
        let twitter = ActionButtonItem(title: "Twitter", image: twitterImage)
        twitter.action = { item in println("Twitter...") }
        
        let google = ActionButtonItem(title: "Google Plus", image: plusImage)
        google.action = { item in println("Google Plus...") }
        
        actionButton = ActionButton(attachedToView: self.view, items: [twitter, google])
        actionButton.action = { button in button.toggleMenu() }
    }
}

