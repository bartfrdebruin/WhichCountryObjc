//
//  WhichCountryVC.swift
//  WhichCountryObjc
//
//  Created by Bart de Bruin on 25-01-16.
//  Copyright © 2016 BartdeBruin. All rights reserved.
//

import UIKit
import MapKit
import CoreGraphics

func getDocumentsURL() -> NSURL {
    
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains:.UserDomainMask)[0]
    return documentsURL
    
}

func fileInDocumentsDirectory(filename: String) -> String {
    
    let uuid = NSUUID().UUIDString
    
    let fileURL = getDocumentsURL().URLByAppendingPathComponent(uuid)
    return fileURL.path!
}


@objc public class WhichCountryVC: UIViewController, UITextFieldDelegate {
    
    
    // MARK: class variables.
    var kmlParser: KMLParser!
    var countries: NSArray
    var pointIsInPolygon: Bool
    var polygonCountryOnTheMap: MKPolygon?
    var snapshotsForCV: NSMutableArray
    
    @IBOutlet var geolocationLatitude: UITextField!
    @IBOutlet var geolocationLongitude: UITextField!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var findButton: UIButton!
    
    
    // MARK: init's
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        self.countries = []
        self.snapshotsForCV = []
        self.pointIsInPolygon = true
        super.init(nibName: "WhichCountryVC", bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: view methods.
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation controller.
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        self.viewSetUp()
        
        let path = NSBundle.mainBundle().pathForResource("world-stripped", ofType: "kml")
        let url = NSURL.fileURLWithPath((path)! as String)
        self.kmlParser = KMLParser(URL: url)
        self.kmlParser.parseKML()
        
        // Setting up the array with polygons
        self.countries = self.kmlParser.overlays
        
        // Delegates
        self.geolocationLatitude.delegate = self
        self.geolocationLongitude.delegate = self
        
        let tapOutsideTextField = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.view.addGestureRecognizer(tapOutsideTextField)
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
    }
    
    func viewSetUp() -> Void {
        
        // Connections with other views.
        let mapviewButton = UIBarButtonItem(title: "MapView", style:.Plain, target: self, action: "mapviewButton:")
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let collectionviewButton = UIBarButtonItem(title: "CollectionView", style: .Plain, target: self, action: "collectionviewButton")
        toolbarItems = [mapviewButton, space, collectionviewButton]
        
        // Find button
        self.findButton.layer.cornerRadius = 5
        
        mapviewButton.enabled = false
        
    }
    
    // MARK: textfield en screen stuff.
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.geolocationLatitude.endEditing(true)
        self.geolocationLatitude.resignFirstResponder()
        self.geolocationLongitude.endEditing(true)
        self.geolocationLongitude.resignFirstResponder()
        
        return true
    }
    

    func handleTap(sender:UITapGestureRecognizer) {
        
        self.geolocationLatitude.resignFirstResponder()
        self.view.endEditing(true)
        self.geolocationLongitude.resignFirstResponder()
        self.view .endEditing(true)
    }
    
    // MARK: mapview.
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
            
            if overlay.isKindOfClass(MKPolygon) {
                
                let overlayView = MKPolygonRenderer(overlay: overlay)
                overlayView.strokeColor = UIColor.redColor()
                overlayView.fillColor = UIColor.greenColor()
                overlayView.alpha = 0.2
                return overlayView
            }
        return nil
    }
    

    // MARK: main finding method.
    @IBAction func findTheCountry(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        let geoLatitude = Double(self.geolocationLatitude.text!)
        let geoLongitude = Double(self.geolocationLongitude.text!)
        
        // Looping through the polygon's obtained by the kml parser.
        for country in self.countries as! [MKPolygon] {
            
            // Two properties to compare.
            let mutablePathReference = CGPathCreateMutable()
            let countryPolygonPoints = country.points()
            
            // Looping through the path.
            for var point = 0; point < country.pointCount; ++point {
                
                // Creating the path
                let mapPoint = countryPolygonPoints[point] as MKMapPoint
                
                if (point == 0) {
                    CGPathMoveToPoint(mutablePathReference, nil,(CGFloat(mapPoint.x)),(CGFloat(mapPoint.y)))
                } else {
                    CGPathAddLineToPoint(mutablePathReference, nil, (CGFloat(mapPoint.x)), CGFloat(mapPoint.y))
                }
            }
            
            let c2d = CLLocationCoordinate2DMake(geoLatitude!, geoLongitude!)
            let cMapPoint = MKMapPointForCoordinate(c2d)
            let coordinatePoint = CGPointMake((CGFloat(cMapPoint.x)),(CGFloat(cMapPoint.y)))
            
            // Checking if the point lies within the polygon.
            self.pointIsInPolygon = CGPathContainsPoint(mutablePathReference, nil, coordinatePoint, false)
            
            // If the point lies within the polygon, using the polygon to draw it as an overlay on the map.
            if (self.pointIsInPolygon) {
                
                print(country.title)
                var flyto: MKMapRect = MKMapRectNull
                
                self.mapView.addOverlay(country)
                flyto = country.boundingMapRect
                
                self.mapView.visibleMapRect = flyto
                self.savingTheMapView()
                
                break
                
                // If no matching polygon has been found.
            } else {
                print("bummer")
            }
        }
        
        // Coordinate lies within the ocean.
        if (!self.pointIsInPolygon) {
            
            let alert = UIAlertController(title: "Oops", message: "Either you've done something wrong, or you wanted to swim!",
                preferredStyle:UIAlertControllerStyle.Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style:.Cancel, handler: nil)
            alert.addAction(defaultAction)
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func savingTheMapView() -> Void {
        
        let snapshotOptions = MKMapSnapshotOptions()
        snapshotOptions.region = mapView.region
        snapshotOptions.size = mapView.frame.size
        snapshotOptions.scale = UIScreen.mainScreen().scale
        
        let snapshotter = MKMapSnapshotter(options: snapshotOptions)
        snapshotter.startWithCompletionHandler { snapshot, error in
            
            if let snapshot = snapshot {
  
                self.snapshotsForCV.addObject(snapshot.image)
                
                let imageDirectory = "images"
                let imagePath = fileInDocumentsDirectory(imageDirectory)
                self.savingSnapshotLocally(snapshot, path: imagePath)
                
                
            } else {
                print("Snapshot error: \(error)")
                return
            }
        }
    }
    
    func savingSnapshotLocally(snapshot: MKMapSnapshot, path: String) -> Bool {
    
        // Passing the image as data.
        let imageData = UIImagePNGRepresentation(snapshot.image)
        let result = imageData?.writeToFile(path, atomically: true)
        
        return result!
    }
    
        func collectionviewButton() -> Void {
        
        let countryCollectionVC = CountryCollectionVC()
        
        // Passing on the snapshots.
        countryCollectionVC.collectionViewSnapshots = self.snapshotsForCV
        self.navigationController?.pushViewController(countryCollectionVC, animated: true)
    }
    
}
