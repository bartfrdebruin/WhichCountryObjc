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

@interface WhichCountryVC () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) KMLParser *kmlParser;
@property (nonatomic, strong) NSArray *countries;
@property (strong, nonatomic) IBOutlet UITextField *geoLocationLatitude;
@property (strong, nonatomic) IBOutlet UITextField *geoLocationLongitude;
@property (nonatomic) CLLocationCoordinate2D locationInAmsterdam;
@property (nonatomic, strong) MKPolygon *polygonCountryOnTheMap;
@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic) BOOL pointIsInPolygon;
@property (strong, nonatomic) IBOutlet UIButton *findButton;

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
    
    
    
    // Delegates.
    self.geoLocationLatitude.delegate = self;
    self.geoLocationLongitude.delegate = self;
    
    // Handle tap, to ensure the keyboard disappears.
    UITapGestureRecognizer *tapOutsiteTextField = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleTap:)];
    
    [self.view addGestureRecognizer:tapOutsiteTextField];

    self.findButton.layer.cornerRadius = 5;

}


#pragma mark textField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.geoLocationLatitude endEditing:YES];
    [self.geoLocationLatitude resignFirstResponder];
    [self.geoLocationLongitude endEditing:YES];
    [self.geoLocationLongitude resignFirstResponder];
    
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    
    [self.geoLocationLatitude resignFirstResponder];
    [self.view endEditing:YES];
    [self.geoLocationLongitude resignFirstResponder];
    [self.view endEditing:YES];
}


#pragma mark Overlay Renderer 

- (MKPolygonRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonRenderer* aView = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon*)overlay];
        aView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
        return aView;
    }
    return nil;
    
}

#pragma mark find the country


- (IBAction)findTheCountry:(id)sender {
    
    [self.view endEditing:YES];
    
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
        self.pointIsInPolygon = CGPathContainsPoint(mutablePathReference, NULL, coordinatePoint, FALSE);
        
        if(self.pointIsInPolygon) {
            
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
    
    // What to do, if no results have been found.
    if (!self.pointIsInPolygon) {
        
        // Coordinate lies within the ocean.
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Oops!"
                                                                       message:@"Either you've done something wrong, or you wanted to swim!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


@end
