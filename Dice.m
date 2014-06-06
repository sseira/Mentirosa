//
//  Dice.m
//  Mentirosa
//
//  Created by Santiago Seira on 11/21/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import "Dice.h"

@implementation Dice

+ (Dice*) initAsHidden {
    Dice *dice = [[Dice alloc] init];
    dice.hidden = YES;
    dice.value = -1;
    return dice;
}


- (void) roll {
    if (self.hidden) {
        NSInteger value_index = arc4random() % 6;
        
        self.value = value_index;
    }
}

- (NSString*)getValueString {
    NSString *value = [[Dice validValues] objectAtIndex:self.value];
    return value;
}


+ (NSArray *)validValues {
    //return @[@"n", @"t", @"J", @"Q", @"K", @"A"]; numbers used instead of letters for sorting purposes
    return @[@"6", @"5", @"4", @"3", @"2", @"1"];
}
@end
