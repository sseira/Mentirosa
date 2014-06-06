//
//  EndTurnViewController.h
//  Mentirosa
//
//  Created by Santiago Seira on 11/28/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"
#import "Game.h"
#import "DecisionViewController.h"

@interface EndTurnViewController : UIViewController
@property (strong, nonatomic) Player *losing_player;
@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) NSString *challenged_lie;
@end
