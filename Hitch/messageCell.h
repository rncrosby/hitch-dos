//
//  messageCell.h
//  Hitch
//
//  Created by Robert Crosby on 8/10/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface messageCell : UITableViewCell {
    
}


@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *initial;

@end
