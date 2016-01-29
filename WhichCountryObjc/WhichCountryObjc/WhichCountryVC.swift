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

@objc class WhichCountryVC: UIViewController, UITextFieldDelegate {
    
    
    // Properties
    var kmlParser: KMLParser!
    var countries: NSArray
    var pointIsInPolygon: Bool
    var polygonCountryOnTheMap: MKPolygon?
    var countriesForCollectionView: NSMutableArray
    
    @IBOutlet var geolocationLatitude: UITextField!
    @IBOutlet var geolocationLongitude: UITextField!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var findButton: UIButton!
    
    
    // Init's.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        self.countries = []
        self.countriesForCollectionView = []
        self.pointIsInPolygon = true
        super.init(nibName: "WhichCountryVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // View did load.
    override func viewDidLoad() {
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
    
    
    // Setting up the view.
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
    
    func collectionviewButton() -> Void {
        
        let countryCollectionVC = CountryCollectionVC()
        self.navigationController?.pushViewController(countryCollectionVC, animated: true)
    }
    
    // Textfields.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
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
                self.countriesForCollectionView.addObject(country)
                flyto = country.boundingMapRect
                
                self.mapView.visibleMapRect = flyto
                
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
    

}
