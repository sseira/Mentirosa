//
//  Dice.h
//  Mentirosa
//
//  Created by Santiago Seira on 11/21/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DieView.h"

@interface Dice : NSObject
@property (nonatomic) NSInteger value;
@property (nonatomic) BOOL hidden;
@property (nonatomic, strong) DieView *view;

- (void) roll;
- (NSString*)getValueString;
+ (Dice*) initAsHidden;
+ (NSArray *)validValues;
@end

#define DICE_SIZE 45