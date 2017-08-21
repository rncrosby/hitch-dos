//
//  transactionObject.m
//  Hitch
//
//  Created by Robert Crosby on 8/21/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "transactionObject.h"

@implementation transactionObject

-(instancetype)initWithType:(NSString*)rideID andAmount:(double)amount andIsIncome:(BOOL)isIncome andDate:(NSDate*)date{
    self = [super init];
    if(self)
    {
        self.amount = [NSNumber numberWithDouble:amount];
        self.rideID = rideID;
        self.isIncome = [NSNumber numberWithBool:isIncome];
        self.date = date;
    }
    return self;
}



@end
