//
//  feedView.h
//  Hitch
//
//  Created by Robert Crosby on 8/6/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "feedCell.h"
#import "References.h"
#import <CoreLocation/CoreLocation.h>
#import "rideObject.h"
#import <CloudKit/CloudKit.h>
#import "rideView.h"

@interface feedView : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CLLocationManagerDelegate> {
    CLLocationManager *location;
    CLPlacemark *start,*end;
    NSMutableArray *rides,*rideRecords;
    // SEARCH PANEL
    __weak IBOutlet UITextField *startPoint;
    __weak IBOutlet UITextField *endPoint;
    __weak IBOutlet UILabel *searchCard;
    // MENU BAR
    __weak IBOutlet UILabel *menuCard;
    __weak IBOutlet UIButton *postRide;
    
    
    // OTHER VIEWS
    UIRefreshControl *refreshControl;
    __weak IBOutlet UITableView *table;
}

@end
