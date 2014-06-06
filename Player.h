//
//  Player.h
//  Mentirosa
//
//  Created by Santiago Seira on 11/21/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (strong, nonatomic) NSString* name;
@property (nonatomic) NSInteger lives_left;
+(Player*) initWithName:(NSString*)name ;
-(void)restartLives;

@end

#define NUM_LIVES 3