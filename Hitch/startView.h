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
    bool isSignIn;
    NSString *phone,*name,*email,*code;
    NSArray *schoolEmails;
    UILabel *blurBack;
    int currentPage;
    UIView *bgVideo;
    UIToolbar *numberToolbar;
    __weak IBOutlet UILabel *card;
    CGRect ogTitle,ogTitleInstruct,ogMainInput;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *titleInstruction;
    __weak IBOutlet UITextField *mainInput;
    __weak IBOutlet UIButton *toggleDogButton;
    __weak IBOutlet UIButton *testAccount;
    UINotificationFeedbackGenerator *feedback;
    /*
    __weak IBOutlet UILabel *shadow;
    __weak IBOutlet UILabel *menuBar;
    __weak IBOutlet UITextField *emailAddress;
    __weak IBOutlet UITextField *name;
     */
}
- (IBAction)testAccount:(id)sender;
@property (nonatomic, strong) AVPlayer *avplayer;
- (IBAction)toggleDog:(id)sender;


@end
