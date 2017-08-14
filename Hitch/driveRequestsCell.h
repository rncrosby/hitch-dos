//
//  driveRequestsCell.h
//  Hitch
//
//  Created by Robert Crosby on 8/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface driveRequestsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *picutre;
@property (weak, nonatomic) IBOutlet UILabel *initial;
@property (weak, nonatomic) IBOutlet UIButton *confirm;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@end
