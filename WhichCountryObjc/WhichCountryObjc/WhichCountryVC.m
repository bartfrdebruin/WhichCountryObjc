//
//  WhichCountryVC.m
//  WhichCountryObjc
//
//  Created by Bart de Bruin on 15-01-16.
//  Copyright © 2016 BartdeBruin. All rights reserved.
//

#import "WhichCountryVC.h"
#import "KMLParser.h"
#import <MapKit/MapKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface WhichCountryVC ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) KMLParser *kmlParser;
@property (nonatomic, strong) NSArray *countries;
@property (strong, nonatomic) IBOutlet UITextField *geoLocation;
@property (nonatomic) CLLocationCoordinate2D locationInAmsterdam;
@property (nonatomic, strong) MKPolygon *polygonCountryOnTheMap;
@property (nonatomic, strong) NSArray *annotations;

@end

@implementation WhichCountryVC 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setting up KML and parser.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"world-stripped"  ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.kmlParser = [[KMLParser alloc] initWithURL:url];
    [self.kmlParser parseKML];
    
    // Setting up the array with polygons.
    self.countries = [self.kmlParser overlays];

    // Creating a CLLocationCoordinate2D for testing.
    //CLLocationDegrees latitude = 5.72277593612671;
    //CLLocationDegrees longitude = 50.96525955200195;
    CLLocationDegrees latitude = 50.850340;
    CLLocationDegrees longitude = 4.351710;
    
    self.locationInAmsterdam = CLLocationCoordinate2DMake(longitude, latitude);
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    self.annotations = [self.kmlParser points];
}


#pragma mark

// Zooming in to our location
- (void)mapView:(MKMapView * _Nonnull)mapView didUpdateUserLocation:(MKUserLocation * _Nonnull)userLocation {
    
    CLLocationCoordinate2D loc = [userLocation coordinate];
    MKCoordinateRegion region =
    
    MKCoordinateRegionMakeWithDistance(loc, 1000, 1000);
    [mapView setRegion:region animated:YES];
}


#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    return [self.kmlParser rendererForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    return [self.kmlParser viewForAnnotation:annotation];
}

#pragma mark find the country

- (CGPoint)pointForMapPoint:(MKMapPoint)mapPoint {
    
    
    return CGPointMake(mapPoint.x, mapPoint.y);
    
}



- (IBAction)findTheCountry:(id)sender {
    
    // The two properties to compare.
    CGMutablePathRef mutablePathReference = CGPathCreateMutable();
    CGPoint polygonCoordinatePoint = CGPointMake(self.locationInAmsterdam.longitude, self.locationInAmsterdam.latitude);
    
    // Looping through the polygon's, obtained by the kml parser.
    for (MKPolygon *country in self.countries) {
        
        // Looping through the path.
        MKMapPoint *countryPolygonPoints = country.points;
        for (int p=0; p < country.pointCount; p++) {
            
            // Creating the path.
            MKMapPoint mapPoint = countryPolygonPoints[p];
            if (p == 0) {
                CGPathMoveToPoint(mutablePathReference, NULL, mapPoint.x, mapPoint.y);
            } else {
                CGPathAddLineToPoint(mutablePathReference, NULL, mapPoint.x, mapPoint.y);
            }
            
        }
        
        // Checking if the point lies inside the polygon.
        BOOL pointIsInPolygon = CGPathContainsPoint(mutablePathReference, NULL, polygonCoordinatePoint, FALSE);

        
        NSLog(@"%@",country.title);
        if(!pointIsInPolygon) {
            NSLog(@"bummer");

        } else if (pointIsInPolygon)
            {
                NSLog(@"We've finally got a winner");
            }
        
        }
    }

//            // Checking if the point lies inside the polygon.
//            BOOL pointIsInPolygon = CGPathContainsPoint(mutablePathReference, NULL, polygonCoordinatePoint, FALSE);
            
//            if (pointIsInPolygon) {
//                
//                // Giving the country's property polygon to the property that needs to be drawn on the map.
//                self.polygonCountryOnTheMap = country;
//                CGPathRelease(mutablePathReference);
//            }
//            
//        } if (self.polygonCountryOnTheMap != nil) {
//            break;
//        }
//    }
//    
//    // Walk the list of overlays and annotations and create a MKMapRect that
//    // bounds all of them and store it into flyTo.
//    MKMapRect flyTo = MKMapRectNull;
//    for (id <MKOverlay> overlay in self.countries) {
//        if (MKMapRectIsNull(flyTo)) {
//            flyTo = [overlay boundingMapRect];
//        } else {
//            flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
//        }
//    }
//    
//    for (id <MKAnnotation> annotation in self.annotations) {
//        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
//        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
//        if (MKMapRectIsNull(flyTo)) {
//            flyTo = pointRect;
//        } else {
//            flyTo = MKMapRectUnion(flyTo, pointRect);
//        }
//    }
//    
//    // Position the map so that all overlays and annotations are visible on screen.
//    self.mapView.visibleMapRect = flyTo;


    
        


@end
