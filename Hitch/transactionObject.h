//
//  transactionObject.h
//  Hitch
//
//  Created by Robert Crosby on 8/21/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface transactionObject : NSObject

@property (nonatomic, strong) NSString* rideID;
@property (nonatomic, strong) NSNumber* amount;
@property (nonatomic, strong) NSNumber* isIncome;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSString* from;
@property (nonatomic, strong) NSString* to;
@property (nonatomic, strong) NSNumber *chargeAmount;

-(instancetype)initWithType:(NSString*)rideID andAmount:(double)amount andIsIncome:(BOOL)isIncome andDate:(NSDate*)date isFrom:(NSString*)from isTo:(NSString*)to andChargeAmount:(double)chargeAmount;

@end
