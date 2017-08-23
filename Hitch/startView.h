//
//  startView.h
//  Hitch
//
//  Created by Robert Crosby on 8/8/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "feedView.h"
#import "References.h"
#import <CloudKit/CloudKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface startView : UIViewController <UITextFieldDelegate> {
    
    UIView *bgVideo;
    __weak IBOutlet UILabel *card;
    __weak IBOutlet UILabel *shadow;
    __weak IBOutlet UILabel *menuBar;
    __weak IBOutlet UITextField *emailAddress;
    __weak IBOutlet UITextField *name;
}
@property (nonatomic, strong) AVPlayer *avplayer;
- (IBAction)continueButton:(id)sender;
- (IBAction)driver:(id)sender;
- (IBAction)rider:(id)sender;
- (IBAction)email:(id)sender;


@end
