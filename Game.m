//
//  Game.m
//  Mentirosa
//
//  Created by Santiago Seira on 11/21/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import "Game.h"
#import "Dice.h"

@interface Game()
@property (strong, nonatomic) NSArray *static_value_array;
@property (strong, nonatomic) NSArray *original_players;
@end

@implementation Game

+(Game*) initGameWithPlayers:(NSMutableArray*) players {
    
    Game *game = [[Game alloc] init];
    game.players = players;
    game.original_players = [NSArray arrayWithArray:players];
    game.current_turn = [game.players firstObject];
    game.lowest_possible_section = 0;
    game.lowest_possible_index = 0;
    
    game.dice = [Game newDice];

    game.static_value_array = game.value_array;
    return game;
}

-(void)restartGame {
    self.players = [NSMutableArray arrayWithArray: self.original_players];
    
    for (Player *player in self.players) {
        [player restartLives];
    }
    self.current_turn = [self.players firstObject];
    self.lowest_possible_section = 0;
    self.lowest_possible_index = 0;
}

+(NSMutableArray*)valueArray {
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    
    for (int i = 2; i<=NUM_DICE; i++) {
        NSMutableArray *values = [[NSMutableArray alloc] init];
        
        for (NSString *value in [Dice validValues]) {
            NSMutableString *string_value = [[NSMutableString alloc] initWithString: value];
            for (int j = 1; j<i; j++) {
                [string_value appendString:value];
            }
            [values addObject:string_value];
        }
        [sections addObject:values];
        
        
        // add 2 pair options
        if (i == 2) {
            values = [[NSMutableArray alloc] init];
            for (int high_pair = 1; high_pair<[[Dice validValues] count]; high_pair++) {
                for (int low_pair = 0; low_pair<high_pair; low_pair++) {
                    NSMutableString *two_pair = [[NSMutableString alloc] init];
                    for (int j = 0; j<i; j++) {
                        [two_pair appendString:[[Dice validValues] objectAtIndex:high_pair]];
                    }
                    for (int j = 0; j<i; j++) {
                        [two_pair appendString:[[Dice validValues] objectAtIndex:low_pair]];
                    }
                    [values addObject:two_pair];
                }
            }
            [sections addObject:values];
        }
        
        
        //add full house options
        if (i == 3) {
            values = [[NSMutableArray alloc] init];
            for (NSString *triple_value in [Dice validValues]) {
                
                NSMutableString *string_value = [[NSMutableString alloc] initWithString: triple_value];
                for (int j = 1; j<i; j++) {
                    [string_value appendString:triple_value];
                }
                
                for (NSString *pair_value in [Dice validValues]) {
                    if (![pair_value isEqualToString:triple_value]){
                        NSMutableString *full_house = [[NSMutableString alloc] initWithString:string_value];
                        // add pairs
                        for (int j = 0; j<2; j++) {
                            [full_house appendString:pair_value];
                        }
                        [values addObject:full_house];
                    }
                }
            }
            [sections addObject:values];
        }
    }
    return sections;
}


+(NSMutableArray*) newDice {
    NSMutableArray *dice_roll = [[NSMutableArray alloc] init];
    for (int i=0; i<NUM_DICE; i++) {
        Dice *dice = [Dice initAsHidden];
        [dice_roll addObject:dice];
    }
    return  dice_roll;
}

-(void)newTurn {
    self.dice = [Game newDice];
    self.lowest_possible_section = 0;
    self.lowest_possible_index = 0;
    self.value_array = nil;
}

-(void)adjustValueArray{
    
    NSRange possible_section_range;
    possible_section_range.location = self.lowest_possible_section;
    possible_section_range.length = [self.value_array count] - possible_section_range.location;
    
    NSMutableArray *possible_lies = [[NSMutableArray alloc] initWithArray: [self.value_array subarrayWithRange:possible_section_range]];
    
    NSRange possible_index_range;
    possible_index_range.location = self.lowest_possible_index;
    possible_index_range.length = [[possible_lies firstObject] count] - possible_index_range.location;
    
    possible_lies[0] = [[possible_lies firstObject] subarrayWithRange: possible_index_range];
    self.value_array = possible_lies;
}



-(NSMutableArray*)value_array {
    
    if (!_value_array) {
       
        _value_array = [Game valueArray];
    }
    return _value_array;
}

- (NSString*)rollAnnouncementWithMinValue:(NSString*)min_value {
    
    // create an array representation of dice and sort alphabetically
    NSMutableArray *roll = [[NSMutableArray alloc] init];
    for (Dice *dice in self.dice) {
        [roll addObject: [dice getValueString]];
    }
    [roll sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    //string representation of roll without singles
    NSMutableString *roll_string = [[NSMutableString alloc] init];
    if ([[roll objectAtIndex:0] isEqualToString:[roll objectAtIndex:1]]) {
        [roll_string appendString:[roll objectAtIndex:0]];
    }
    for (int i=1; i<NUM_DICE-1; i++) {
        if ([[roll objectAtIndex:i] isEqualToString:[roll objectAtIndex:i+1]]
            || [[roll objectAtIndex:i] isEqualToString:[roll objectAtIndex:i-1]]) {
            [roll_string appendString:[roll objectAtIndex:i]];
        }
    }
    if ([[roll objectAtIndex:NUM_DICE-1] isEqualToString:[roll objectAtIndex:NUM_DICE-2]]) {
        [roll_string appendString:[roll objectAtIndex:NUM_DICE-1]];
    }
    
    // find highest value in game.static_value_array that is in roll_string
    for (NSArray *section in [self.static_value_array reverseObjectEnumerator]) {
        for (NSString *string_value in [section reverseObjectEnumerator]){
            
            NSMutableArray *array_value = [[NSMutableArray alloc] init];
            for (int j = 0; j<[string_value length]; j++) {
                [array_value addObject:[[NSString alloc] initWithString:[string_value substringWithRange:NSMakeRange(j, 1)]]];
            }
            
            [array_value sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            // convert to array
            // sort it
            // back to string
            NSMutableString *string_value_mutable = [[NSMutableString alloc] init];
            for (NSString *value in array_value) {
                [string_value_mutable appendString:value];
            }
            
            if ([roll_string rangeOfString:string_value_mutable].location != NSNotFound) {
                //return string_value_mutable;
                return roll_string;
            }
            
            //if we didnt find it before the min_value, the roll was lower than the lie
            if (min_value
                && [min_value isEqualToString:string_value]) {
                return @"NOT TRUE!";
            }
        }
    }
    return @"PACHUCA!";
}




+(NSString*) prettyfyRoll:(NSString*)roll {
    /*
     Par de Aces / dieces / nueves      Pair of Aces / tens
     Dos pares, Aces y Reinas           Two pairs, aces and queens
     Tercia de Aces                     Three Queens, tens
     Full house, Reyes con aces         Full House, kings with aces
     Poker de Aces                      Poker of Queens
     Quintilla de
     
     
     */

    switch ([roll length]) {
        case 2:
            return [NSString stringWithFormat:@"Par de %@"/*@"Pair of %@"*/, [self prettyfyValue:[roll substringToIndex:1]]];
            break;
            
        case 3:
            return [NSString stringWithFormat:@"3 %@", [self prettyfyValue:[roll substringToIndex:1]]];
            break;
            
        case 4:
            if ([[roll substringToIndex:1] isEqualToString:[roll substringFromIndex:[roll length] -1]]) {
                //poker
                return [NSString stringWithFormat:@"Poker de %@"/*@"Poker of %@"*/, [self prettyfyValue:[roll substringToIndex:1]]];
            } else {
                //dos pares
                return [NSString stringWithFormat:@"2 pares, %@ y %@"/*@"2 pairs, %@ and %@"*/, [self prettyfyValue:[roll substringToIndex:1]], [self prettyfyValue:[roll substringFromIndex:[roll length] -1]]];
            }
            break;
            
        case 5:
            if ([[roll substringToIndex:1] isEqualToString:[roll substringFromIndex:[roll length] -1]]) {
                // quintilla
                return [NSString stringWithFormat:@"Quintilla de %@"/*@"5 %@"*/, [self prettyfyValue:[roll substringToIndex:1]]];
            } else {
                //full house
                return [NSString stringWithFormat:@"Full House, 3 %@ con 2 %@"/*@"Full House, 3 %@ with 2 %@"*/, [self prettyfyValue:[roll substringToIndex:1]], [self prettyfyValue:[roll substringFromIndex:[roll length] -1]]];

            }
            break;
        case 8:
            return roll;
        default:
            return @"ERROR ahh!";
            break;
    }
}

+(NSString*) prettyfyLie:(NSString*)roll {
    /*
     Par de Aces / dieces / nueves      Pair of Aces / tens
     Dos pares, Aces y Reinas           Two pairs, aces and queens
     Tercia de Aces                     Three Queens, tens
     Full house, Reyes con aces         Full House, kings with aces
     Poker de Aces                      Poker of Queens
     Quintilla de
     
     
     */
    
    switch ([roll length]) {
        case 2:
            return [self prettyfyValue:[roll substringToIndex:1]];
            break;
            
        case 3:
            return [self prettyfyValue:[roll substringToIndex:1]];
            break;
            
        case 4:
            if ([[roll substringToIndex:1] isEqualToString:[roll substringFromIndex:[roll length] -1]]) {
                //poker
                return [self prettyfyValue:[roll substringToIndex:1]];
            } else {
                //dos pares
                return [NSString stringWithFormat:@"%@ y %@"/*@"%@ and %@"*/, [self prettyfyValue:[roll substringToIndex:1]], [self prettyfyValue:[roll substringFromIndex:[roll length] -1]]];
            }
            break;
            
        case 5:
            if ([[roll substringToIndex:1] isEqualToString:[roll substringFromIndex:[roll length] -1]]) {
                // quintilla
                return [self prettyfyValue:[roll substringToIndex:1]];
            } else {
                //full house
                return [NSString stringWithFormat:@"3 %@ con 2 %@"/*@"3 %@ with 2 %@"*/, [self prettyfyValue:[roll substringToIndex:1]], [self prettyfyValue:[roll substringFromIndex:[roll length] -1]]];
            }
            break;
            
        default:
            return @"ERROR ahh!";
            break;
    }
}

+(NSString*)prettyfyValue:(NSString*)value {
    
    if ([value isEqualToString:@"1"]) {
        return @"Aces";
    } else if ([value isEqualToString:@"2"]) {
//        return @"Kings";
        return @"Reyes";
    } else if ([value isEqualToString:@"3"]) {
//        return @"Queens";
        return @"Reinas";
    } else if ([value isEqualToString:@"4"]) {
//        return @"Jacks";
        return @"Jotos";
    } else if ([value isEqualToString:@"5"]) {
        //        return @"Tens";
        return @"Dieces";
    } else if ([value isEqualToString:@"6"]) {
//        return @"Nines";
        return @"Nueves";
    } else {
        return @"Error Auxilio!!!";
    }
}

-(Player*)nextPlayer {
    NSInteger next_player_index = [self.players indexOfObject:self.current_turn] + 1;
    next_player_index = next_player_index < [self.players count] ? next_player_index : 0;
    Player *next_player = [self.players objectAtIndex:next_player_index];
    return next_player;
}


@end
