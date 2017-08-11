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
#import "driveRequestsCell.h"
#import "messageCell.h"

@interface rideView : UIViewController <UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UITextFieldDelegate> {
    UIView *line;
    CGRect keyboard;
    bool isRideConfirmed;
    MKPolyline *routeLine;
    MKPolylineView *routeLineView;
    NSMutableArray *messages;
    NSMutableArray *riderColorMatch;
    NSMutableArray *passengers;
    __weak IBOutlet UILabel *menuBar;
    __weak IBOutlet UILabel *menuBarTitle;
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
    __weak IBOutlet UILabel *contactInitial;
    
    // ismyride panel
    __weak IBOutlet UILabel *ridePanel;
    __weak IBOutlet UILabel *ridePanelShadow;
    __weak IBOutlet UITableView *rideTable;
    
    __weak IBOutlet UILabel *ridePanelMessage;
    __weak IBOutlet UITextField *ridePanelMessageField;
    __weak IBOutlet UIButton *ridePanelSendMessage;
    
    __weak IBOutlet UILabel *rideManagerCard;
    __weak IBOutlet UILabel *rideManagerShadow;
    __weak IBOutlet UIButton *rideManagerTrash;
    __weak IBOutlet UIButton *rideManagerMap;
    __weak IBOutlet UIButton *rideManagerShare;
    
    
    __weak IBOutlet UIButton *ridersButton;
    __weak IBOutlet UIButton *messagesButton;
    __weak IBOutlet UILabel *noRiders;
}

- (IBAction)requestRide:(id)sender;
@property (nonatomic, retain) rideObject *ride;
@property (nonatomic, retain) CKRecord *rideRecord;
- (IBAction)sendMessage:(id)sender;
- (IBAction)showMessages:(id)sender;
- (IBAction)showRiders:(id)sender;
- (IBAction)messageDidStart:(id)sender;
- (IBAction)sendGroupMessage:(id)sender;
- (IBAction)showKeyboard:(id)sender;

- (IBAction)back:(id)sender;

- (IBAction)shareRide:(id)sender;
- (IBAction)openDirections:(id)sender;
- (IBAction)deleteDrive:(id)sender;


@end
