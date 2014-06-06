//
//  Game.h
//  Mentirosa
//
//  Created by Santiago Seira on 11/21/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@interface Game : NSObject
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableArray *dice;
@property (strong, nonatomic) NSMutableArray *value_array;
@property (strong, nonatomic) Player *current_turn;
@property (nonatomic) NSInteger lowest_possible_section;
@property (nonatomic) NSInteger lowest_possible_index;

+(Game*) initGameWithPlayers:(NSMutableArray*) players;
- (NSString*)rollAnnouncementWithMinValue:(NSString*)min_value;
+(NSString*) prettyfyRoll:(NSString*)roll;
+(NSString*) prettyfyLie:(NSString*)roll;
-(void)newTurn;
-(void)adjustValueArray;
-(Player*)nextPlayer;
-(void)restartGame;
+(NSMutableArray*)valueArray;

@end


#define NOT_TRUE @"NOT TRUE!"
#define NUM_DICE 5