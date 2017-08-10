//
//  rideView.m
//  Hitch
//
//  Created by Robert Crosby on 8/7/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "rideView.h"

@interface rideView ()

@end

@implementation rideView

- (void)viewDidLoad {
    [References createLine:self.view xPos:0 yPos:menuBar.frame.origin.y+menuBar.frame.size.height inFront:TRUE];
    from.text = _ride.plainStart;
    to.text = _ride.plainEnd;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h a"];
    date.text = [NSString stringWithFormat:@"%@ around %@",[dateFormatter stringFromDate:_ride.date],[timeFormatter stringFromDate:_ride.date]];
    [References cardshadow:cardShadow];
    [References cornerRadius:card radius:8.0f];
    [References cardshadow:mapShadow];
    [References cornerRadius:map radius:8.0f];
    [References cardshadow:contactShadow];
    [References cornerRadius:contactCard radius:8.0f];
    [References cornerRadius:contactImage radius:contactImage.frame.size.width/2];
    [contactImage setImage:[UIImage imageNamed:@"user.jpg"]];
    if (_ride.price.intValue > 0) {
        price.text = [NSString stringWithFormat:@"$%i",_ride.price.intValue];
    } else {
        price.text = @"Free";
    }
    [References cornerRadius:price radius:8.0f];
    [References cardshadow:priceShadow];
    [self loadMap];
    contactName.text = _ride.name;
    seats.text = [NSString stringWithFormat:@"%i",_ride.seats.intValue];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(id)sender {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] isEqualToString:_ride.phone]) {
        [References toastMessage:@"You can't contact your self" andView:self];
    } else {
        [References toastMessage:@"Soon" andView:self];
    }
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadMap {
    MKCoordinateRegion region = map.region;
    region.span.longitudeDelta /= 8.0;
    region.span.latitudeDelta /= 8.0;
    
    [map setRegion:region animated:YES];
    MKPointAnnotation *start = [[MKPointAnnotation alloc] init];
    start.coordinate = _ride.start.coordinate;
    [start setTitle:_ride.plainStart];
    MKPointAnnotation *end = [[MKPointAnnotation alloc] init];
    [end setTitle:_ride.plainEnd];
    end.coordinate = _ride.end.coordinate;
    [map addAnnotation:start];
    [map addAnnotation:end];
    [self zoomToFitMapAnnotations:map];
}

-(void)zoomToFitMapAnnotations:(MKMapView*)mapView
{
    if([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(CLLocation* annotation in mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 2.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 2.1; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

- (IBAction)requestRide:(id)sender {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] isEqualToString:_ride.phone]) {
        [References toastMessage:@"You can't contact your self" andView:self];
    } else {
        NSMutableArray *newRequests = [[NSMutableArray alloc] initWithArray:[_rideRecord objectForKey:@"requests"]];
        [newRequests addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
        _rideRecord[@"requests"] = newRequests;
        CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                                  initWithRecordsToSave:[[NSArray alloc] initWithObjects:_rideRecord, nil] recordIDsToDelete:nil];
        modifyRecords.savePolicy=CKRecordSaveAllKeys;
        modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
        modifyRecords.modifyRecordsCompletionBlock=
        ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
            //   the completion block code here
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self addToMyRides];
            });
        };
        CKContainer *defaultContainer = [CKContainer defaultContainer];
        [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
}
}

-(void)addToMyRides{
    NSString *string = [NSString stringWithFormat:@"email = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"People" predicate:predicate];
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            CKRecord *record = results[0];
            NSMutableArray *newRequests = [[NSMutableArray alloc] initWithArray:[record objectForKey:@"myRides"]];
            [newRequests addObject:_ride.phone];
            record[@"myRides"] = newRequests;
            CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                                      initWithRecordsToSave:[[NSArray alloc] initWithObjects:record, nil] recordIDsToDelete:nil];
            modifyRecords.savePolicy=CKRecordSaveAllKeys;
            modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
            modifyRecords.modifyRecordsCompletionBlock=
            ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
                //   the completion block code here
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [References toastMessage:@"Ride Requested" andView:self];
                });
            };
            CKContainer *defaultContainer = [CKContainer defaultContainer];
            [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
        }
        else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
}
    
@end
