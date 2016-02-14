//
//  CountryCollectionVC.swift
//  WhichCountryObjc
//
//  Created by Bart de Bruin on 28-01-16.
//  Copyright © 2016 BartdeBruin. All rights reserved.
//

import UIKit

class CountryCollectionVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    // MARK: properties.
    var collectionView: UICollectionView!
    var collectionViewSnapshots: NSMutableArray?
    var urlConcents: NSArray?
    
    // MARK: view did load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewSetUp()
        self.collectionviewSetUp()
        self.findMyStoredImages()
    }
    
    // MARK: getting image data. 
    
    func findMyStoredImages() -> Void {
        
        // Passing the bundleurl.
        let bundleURL = getDocumentsURL()
        
        // Getting url content.
        do {
            self.urlConcents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(bundleURL, includingPropertiesForKeys: nil, options:NSDirectoryEnumerationOptions(rawValue: 0))
        }
        // error handling.
        catch let error as NSError  {
            print(error.description)
        }
        
        for image in self.urlConcents! {
            
            print("Found \(image)")
        }
    }
    
    // MARK: setting up the view.
    
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
    
    func loadImageFromPath(path: String) -> UIImage? {
        
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("missing image at: \(path)")
        }
        print("loading image from path: \(path)")
        return image
    }
    
    
    // MARK: collection view
    
    func collectionviewSetUp() -> Void {
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150, height: 150)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let countryCVCNib = UINib(nibName: "CountryCollectionViewCell", bundle:nil)
        collectionView.registerNib(countryCVCNib, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.redColor()
        
        self.view.addSubview(collectionView)
    }
    
    
    // MARK: collection view datasource. 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.collectionViewSnapshots!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CountryCollectionViewCell
        let collectionviewSnapshot = self.collectionViewSnapshots![indexPath.row]
        
        cell.collectionviewImage.image = collectionviewSnapshot as? UIImage
        cell.collectionviewImage.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        return cell
    }
    
    
    
    
    
    
 
    
  

}
