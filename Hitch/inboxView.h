//
//  inboxView.h
//  Hitch
//
//  Created by Robert Crosby on 8/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "References.h"
#import <CloudKit/CloudKit.h>
#import "rideObject.h"
#import "driveRequestsCell.h"
#import "feedCell.h"

@interface inboxView : UIViewController <UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *myRides,*myRideRecords;
    rideObject *myDrive;
    CKRecord *myDriveRecord;
    __weak IBOutlet UILabel *menuBar;
    
    // drive details
    __weak IBOutlet UILabel *driveCard;
    __weak IBOutlet UILabel *driveShadow;
    __weak IBOutlet UILabel *driveFrom;
    __weak IBOutlet UILabel *driveTo;
    __weak IBOutlet UILabel *driveDate;
    __weak IBOutlet UILabel *driveSeats;
    __weak IBOutlet UILabel *noDriveLabel;
    __weak IBOutlet UILabel *drivePrice;
    __weak IBOutlet UILabel *drivePriceShadow;
    // drive requests
    __weak IBOutlet UILabel *driveRequestsCard;
    __weak IBOutlet UILabel *driveRequestsShadow;
    __weak IBOutlet UITableView *driveRequestsTable;
    __weak IBOutlet UILabel *noRequestsLabel;
    __weak IBOutlet UIButton *showRequests;
    __weak IBOutlet UIButton *showRiders;
    
    // scroll button
    __weak IBOutlet UIButton *scrollButton;
    __weak IBOutlet UIScrollView *scroll;
    
    // ride table
    __weak IBOutlet UILabel *ridesCard;
    __weak IBOutlet UILabel *ridesShadow;
    __weak IBOutlet UILabel *noRidesLabel;
    __weak IBOutlet UITableView *rideTable;
}
- (IBAction)backButton:(id)sender;
- (IBAction)showRequests:(id)sender;
- (IBAction)showRiders:(id)sender;
- (IBAction)scrollButton:(id)sender;

@end
