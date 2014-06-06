//
//  DecisionViewController.m
//  Mentirosa
//
//  Created by Santiago Seira on 11/27/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import "DecisionViewController.h"
#import "EndTurnViewController.h"
#import "Dice.h"

@interface DecisionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *dice_table_view;
@property (weak, nonatomic) IBOutlet UILabel *lie_announcement;
@property (weak, nonatomic) IBOutlet UIButton *believe_button;
@property (weak, nonatomic) IBOutlet UIButton *dont_believe_button;


@end

@implementation DecisionViewController

-(BOOL)show_hidden_dice {
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lie_announcement.text = [NSString stringWithFormat:/*@"Claim: %@"*/@"Mentira: %@",[Game prettyfyRoll:self.lie_string]];
    if ([self.lie_string isEqualToString:[[self.game.value_array lastObject] lastObject]]) {
        // cant beat 5 Aces so must disbelieve
        [self.believe_button removeFromSuperview];
    }
    
    [self.dont_believe_button setAttributedTitle:[self.class outlineString:self.dont_believe_button.currentTitle] forState:UIControlStateNormal];

    [self.believe_button setAttributedTitle:[self.class outlineString:self.believe_button.currentTitle] forState:UIControlStateNormal];
}


-(void)viewDidLayoutSubviews {
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        
        if ([(Dice*)[self.game.dice firstObject] value] != -1) {
            [self rearrangeDice];
        }
        

    } else {
        
        if ([(Dice*)[self.game.dice firstObject] value] != -1) {
            [self rearrangeDice];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"believe"]) {
        
        RollViewController *destination_controller = (RollViewController*) segue.destinationViewController;
        destination_controller.game = self.game;
        destination_controller.believed_lie_string = self.lie_string;
    } else if ([segue.identifier isEqualToString:@"dont_believe"]) {
        EndTurnViewController *destination_controller = (EndTurnViewController*)segue.destinationViewController;
        destination_controller.game = self.game;
        destination_controller.challenged_lie = self.lie_string;
        
        NSInteger liar_index = [self.game.players indexOfObject:self.game.current_turn] - 1;
        if (liar_index < 0) {
            liar_index = [self.game.players count] -1;
        }
        
        Player *liar = [self.game.players objectAtIndex:liar_index];
        
        
        if ([[self.game rollAnnouncementWithMinValue:self.lie_string] isEqualToString:NOT_TRUE]) {
            destination_controller.losing_player = liar;
            liar.lives_left--;
            if (liar.lives_left == 0) {
                [self.game.players removeObject:liar];
            } else {
                self.game.current_turn = liar;
            }
            //player before loses a life
        } else {
            destination_controller.losing_player = self.game.current_turn;
            // current player loses a life, not a lie
            self.game.current_turn.lives_left--;
            if (self.game.current_turn.lives_left == 0) {
                [self.game.players removeObject:self.game.current_turn];
                self.game.current_turn = liar;
            }
        }
       
    }
}

@end
