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

@interface inboxView : UIViewController <UITableViewDelegate,UITableViewDataSource> {
    
    rideObject *myDrive;
    __weak IBOutlet UILabel *menuBar;
    
    // drive details
    __weak IBOutlet UILabel *driveCard;
    __weak IBOutlet UILabel *driveShadow;
    __weak IBOutlet UILabel *driveFrom;
    __weak IBOutlet UILabel *driveTo;
    __weak IBOutlet UILabel *driveDate;
    __weak IBOutlet UILabel *driveSeats;
    // drive requests
    __weak IBOutlet UILabel *driveRequestsCard;
    __weak IBOutlet UILabel *driveRequestsShadow;
    __weak IBOutlet UITableView *driveRequestsTable;
    
}
- (IBAction)backButton:(id)sender;

@end
