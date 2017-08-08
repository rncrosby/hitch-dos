//
//  rideView.h
//  Hitch
//
//  Created by Robert Crosby on 8/7/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "References.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "rideObject.h"
#import <CloudKit/CloudKit.h>

@interface rideView : UIViewController <MKMapViewDelegate>{
    MKPolyline *routeLine;
    MKPolylineView *routeLineView;
    __weak IBOutlet UILabel *menuBar;
    __weak IBOutlet UILabel *mapShadow;
    __weak IBOutlet MKMapView *map;
    __weak IBOutlet UILabel *rideTitle;
    __weak IBOutlet UILabel *card;
    __weak IBOutlet UILabel *cardShadow;
    __weak IBOutlet UILabel *from;
    __weak IBOutlet UILabel *to;
    __weak IBOutlet UILabel *date;
    __weak IBOutlet UILabel *seats;
    __weak IBOutlet UIScrollView *scroll;
    __weak IBOutlet UILabel *price;
    __weak IBOutlet UILabel *priceShadow;
    
    // contact
    __weak IBOutlet UILabel *contactShadow;
    __weak IBOutlet UILabel *contactCard;
    __weak IBOutlet UIImageView *contactImage;
    __weak IBOutlet UILabel *contactName;
    __weak IBOutlet UIButton *contactMessage;
    __weak IBOutlet UIButton *requestRide;
    
    
}

- (IBAction)requestRide:(id)sender;
@property (nonatomic, retain) rideObject *ride;
@property (nonatomic, retain) CKRecord *rideRecord;
- (IBAction)sendMessage:(id)sender;

- (IBAction)back:(id)sender;



@end
