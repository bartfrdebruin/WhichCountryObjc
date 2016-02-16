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
    var contentsOfDocumentDirectory: NSArray?
    var shadowLayer: CAShapeLayer!

    
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
            self.contentsOfDocumentDirectory = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(bundleURL, includingPropertiesForKeys: nil, options:NSDirectoryEnumerationOptions(rawValue: 0))
        }
        // error handling.
        catch let error as NSError  {
            print(error.description)
        }
        
        for content in self.contentsOfDocumentDirectory! {
            
            print("Found \(content)")
            
            let imageData = NSData(contentsOfURL: content as! NSURL)
            let image = UIImage(data: imageData!)
            self.collectionViewSnapshots?.addObject(image!)
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
    
    // MARK: collection view
    
    func collectionviewSetUp() -> Void {
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 100, height: 100)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let countryCVCNib = UINib(nibName: "CountryCollectionViewCell", bundle:nil)
        collectionView.registerNib(countryCVCNib, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.whiteColor()

        self.view.addSubview(collectionView)
    }
    
    func layoutSubviews(cell: UICollectionViewCell) {
        
        let subView = UIView(frame: cell.bounds)
        
        subView.layer.shadowColor = UIColor.grayColor().CGColor
        subView.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        subView.layer.shadowRadius = 2
        subView.layer.shadowOpacity = 0.8
        subView.layer.masksToBounds = false

        subView.addSubview(cell)
            
        
    }
//
    
    // MARK: collection view datasource. 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.collectionViewSnapshots!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CountryCollectionViewCell
        let collectionviewSnapshot = self.collectionViewSnapshots![indexPath.row]
        
        cell.collectionviewImage.image = collectionviewSnapshot as? UIImage
        cell.collectionviewImage.layer.cornerRadius = 12
        cell.contentView.clipsToBounds = true
        
        self.layoutSubviews(cell)
        
        return cell
    }
    
    
    
    
    
    
 
    
  

}
