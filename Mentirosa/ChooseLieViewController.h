//
//  ChooseLieViewController.h
//  Mentirosa
//
//  Created by Santiago Seira on 12/5/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"

@interface ChooseLieViewController : UIViewController
@property (strong, nonatomic) NSArray *possible_lies;
@property (weak, nonatomic) IBOutlet UITableView *table_view;
@property (weak, nonatomic) IBOutlet UILabel *lie_to_beat;
@property (strong, nonatomic) NSString *lie_to_beat_string;
@property (strong, nonatomic) Game *game;
@end
