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

@interface WhichCountryVC () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) KMLParser *kmlParser;
@property (nonatomic, strong) NSArray *countries;
@property (strong, nonatomic) IBOutlet UITextField *geoLocationLatitude;
@property (strong, nonatomic) IBOutlet UITextField *geoLocationLongitude;
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
    
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonView* aView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay];
        aView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
        return aView;
    }
    return nil;
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    return [self.kmlParser viewForAnnotation:annotation];
}

#pragma mark find the country


- (IBAction)findTheCountry:(id)sender {
    
    double geoLatitude = [self.geoLocationLatitude.text doubleValue];
    double geoLongitude = [self.geoLocationLongitude.text doubleValue];
    
    // Looping through the polygon's, obtained by the kml parser.
    for (MKPolygon *country in self.countries) {
 
        // The two properties to compare.
        CGMutablePathRef mutablePathReference = CGPathCreateMutable();
        
        // Looping through the path.
        MKMapPoint *countryPolygonPoints = country.points;
        for (int p=0; p < country.pointCount; p++) {
            
            // Creating the path.
            MKMapPoint mapPoint = countryPolygonPoints[p];
            
            //MKMapPoint mapPoint = MKMapPointForCoordinate(countryPolygonPoints[p]);
            if (p == 0) {
                CGPathMoveToPoint(mutablePathReference, NULL, mapPoint.x, mapPoint.y);
            } else {
                CGPathAddLineToPoint(mutablePathReference, NULL, mapPoint.x, mapPoint.y);
            }
        }
        
        // Creating a CGPoint out of a CLLocation.
        CLLocationCoordinate2D c2D = CLLocationCoordinate2DMake(geoLatitude, geoLongitude);
        MKMapPoint cMapPoint = MKMapPointForCoordinate(c2D);
        CGPoint coordinatePoint =  CGPointMake(cMapPoint.x, cMapPoint.y);
        
        // Checking whether point lies within an polygon.
        BOOL pointIsInPolygon = CGPathContainsPoint(mutablePathReference, NULL, coordinatePoint, FALSE);
        
        if(pointIsInPolygon) {
            
            NSLog(@"%@",country.title);
            MKMapRect flyTo = MKMapRectNull;

            [self.mapView addOverlay:country];
            flyTo = [country boundingMapRect];
            self.mapView.visibleMapRect = flyTo;
            
            // Forcing the for loop to quit.
            break;
            
        } else             {
            NSLog(@"Bummer!");
        }
    }
}


@end
