//
//  Player.m
//  Mentirosa
//
//  Created by Santiago Seira on 11/21/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import "Player.h"

@implementation Player
+(Player*) initWithName:(NSString*)name {
    Player* player = [[Player alloc] init];
    player.name = name;
    player.lives_left = NUM_LIVES;
    
    return player;
}

-(void) looseLife {
    self.lives_left--;
}

-(void)restartLives {
    self.lives_left = NUM_LIVES;
}

@end
