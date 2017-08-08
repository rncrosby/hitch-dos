//
//  postView.h
//  Hitch
//
//  Created by Robert Crosby on 8/7/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "References.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CloudKit/CloudKit.h>

@interface postView : UIViewController <CLLocationManagerDelegate,UITextFieldDelegate> {
    CLLocationManager *locationManager;
    CLLocation *location,*endPoint;
    NSDate *actualDate,*actualTime;
    __weak IBOutlet UILabel *menuBar;
    __weak IBOutlet UITextField *from;
    __weak IBOutlet UITextField *to;
    __weak IBOutlet UITextField *date;
    __weak IBOutlet UITextField *time;
    __weak IBOutlet UITextField *seats;
    __weak IBOutlet MKMapView *map;
    __weak IBOutlet UITextField *price;
    CLPlacemark *start,*end;
}

- (IBAction)back:(id)sender;
- (IBAction)submit:(id)sender;

@end
