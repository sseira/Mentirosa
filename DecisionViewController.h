//
//  DecisionViewController.h
//  Mentirosa
//
//  Created by Santiago Seira on 11/27/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "RollViewController.h"

@interface DecisionViewController : RollViewController
@property (strong, nonatomic) NSString *lie_string;
@property (strong, nonatomic) Game *game;
@end
