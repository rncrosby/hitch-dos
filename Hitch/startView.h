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

@interface startView : UIViewController <UITextFieldDelegate> {
    

    __weak IBOutlet UILabel *card;
    __weak IBOutlet UILabel *shadow;
    __weak IBOutlet UILabel *menuBar;
    __weak IBOutlet UITextField *emailAddress;
    __weak IBOutlet UITextField *name;
}

- (IBAction)continueButton:(id)sender;


@end
