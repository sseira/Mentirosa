//
//  RollViewController.h
//  Mentirosa
//
//  Created by Santiago Seira on 11/25/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"


@interface RollViewController : UIViewController
@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) NSString *chosen_lie_string;
@property (strong, nonatomic) NSString *believed_lie_string;
@property (nonatomic) NSInteger chosen_lie_index;
@property (nonatomic) NSInteger chosen_lie_section;
@property (nonatomic) BOOL show_hidden_dice;

- (void)displayPublicDiceAndHidden:(BOOL)show_hidden OnLoad:(BOOL)on_load FromCubilete:(BOOL)from_cubilete;
-(void)rearrangeDice;
+(NSMutableAttributedString*) outlineString:(NSString*)string;
@end

#define TABLE_VIEW_PORTRAIT_WIDTH 320
#define TABLE_VIEW_PORTRAIT_HEIGHT 350

#define TABLE_VIEW_LANDSCAPE_WIDTH 568
#define TABLE_VIEW_LANDSCAPE_HEIGHT 200
