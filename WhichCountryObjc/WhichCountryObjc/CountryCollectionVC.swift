//
//  CountryCollectionVC.swift
//  WhichCountryObjc
//
//  Created by Bart de Bruin on 28-01-16.
//  Copyright © 2016 BartdeBruin. All rights reserved.
//

import UIKit

class CountryCollectionVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewSetUp()
    }
    
    
    
    
    func viewSetUp() -> Void {
        
        // Connections with other views.
        let mapviewButton = UIBarButtonItem(title: "MapView", style:.Plain, target: self, action: "mapviewButton")
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let collectionviewButton = UIBarButtonItem(title: "CollectionView", style: .Plain, target: self, action: "collectionviewButton")
        toolbarItems = [mapviewButton, space, collectionviewButton]
        
        collectionviewButton.enabled = false
    }
    
    func mapviewButton() -> Void {
        
        let whichCountryVC = WhichCountryVC()
        self.navigationController?.pushViewController(whichCountryVC, animated: true)
        
    }
    
    
 
    
  

}
