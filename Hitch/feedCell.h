//
//  feedCell.h
//  Hitch
//
//  Created by Robert Crosby on 8/6/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface feedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *shadow;
@property (weak, nonatomic) IBOutlet UILabel *card;
@property (weak, nonatomic) IBOutlet UILabel *from;
@property (weak, nonatomic) IBOutlet UILabel *to;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *seats;
@property (weak, nonatomic) IBOutlet UIButton *chevron;
@property (weak, nonatomic) IBOutlet UILabel *fromTag;
@property (weak, nonatomic) IBOutlet UILabel *toTag;
@property (weak, nonatomic) IBOutlet UILabel *leavesTag;
@property (weak, nonatomic) IBOutlet UILabel *seatsTag;

@end
