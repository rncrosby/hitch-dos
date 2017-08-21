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
#import "feedView.h"
#import "postView.h"
#import "historyView.h"

@interface feedView : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CLLocationManagerDelegate> {
    CLLocationManager *location;
    bool canMakeDrive;
    CLPlacemark *start,*end;
    NSMutableArray *rides,*rideRecords;
    UINotificationFeedbackGenerator *feedback;
    UISelectionFeedbackGenerator *selectionFeedback;
    // SEARCH PANEL
    __weak IBOutlet UITextField *startPoint;
    __weak IBOutlet UITextField *endPoint;
    __weak IBOutlet UILabel *searchCard;
    __weak IBOutlet UILabel *noRides;
    // MENU BAR
    __weak IBOutlet UILabel *menuCard;
    __weak IBOutlet UIButton *postRide;
    
    __weak IBOutlet UIButton *refreshButton;
    
    // OTHER VIEWS
    UIRefreshControl *refreshControl;
    __weak IBOutlet UITableView *table;
}
@property (nonatomic, retain) NSString *rideToOpen;
- (IBAction)inbox:(id)sender;
- (IBAction)postDrive:(id)sender;
- (IBAction)more:(id)sender;
- (IBAction)refreshButton:(id)sender;

@end
