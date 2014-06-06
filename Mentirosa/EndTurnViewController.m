//
//  EndTurnViewController.m
//  Mentirosa
//
//  Created by Santiago Seira on 11/28/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import "EndTurnViewController.h"
#import "Dice.h"
#import "RollViewController.h"

@interface EndTurnViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *truth_announcement;
@property (weak, nonatomic) IBOutlet UILabel *losing_player_announcement;
@property (weak, nonatomic) IBOutlet UIImageView *dice_table_view;
@property (weak, nonatomic) IBOutlet UIButton *next_turn_button;

@property (weak, nonatomic) IBOutlet UIButton *restart_game_button;
@end

@implementation EndTurnViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [[self navigationController] setNavigationBarHidden:YES];
    [self.truth_announcement sendSubviewToBack:self.dice_table_view];
    
    if ([[self.game rollAnnouncementWithMinValue:self.challenged_lie] isEqualToString:NOT_TRUE]) {
        self.truth_announcement.text = @"Mentira!";//@"It was a lie!";
    } else {
        self.truth_announcement.text = @"Ooops, si estaba!"; //@"Ooops, it was true...";
    }
    
    if ([self.game.players count] > 1) {
        if ([self.game.players indexOfObject:self.losing_player] == NSNotFound ) {
            // losing player just got eliminated
            self.losing_player_announcement.text = [NSString stringWithFormat:/*@"%@ has been eliminated!"*/ @"%@ ha sido eliminado!", self.losing_player.name ];
            
        } else {
            self.losing_player_announcement.text = [NSString stringWithFormat:/*@"%@ lost a life" */ @"%@ perdio una vida", self.losing_player.name ];
        }
        [self.next_turn_button setAttributedTitle:[RollViewController outlineString:self.next_turn_button.currentTitle] forState:UIControlStateNormal];

        [self.restart_game_button removeFromSuperview];
    } else {
        // 1 player just won
        Player* winner = [self.game.players firstObject];
        self.losing_player_announcement.text = [NSString stringWithFormat:/*@"%@ won the game!"*/@"%@ ganó este juego!", winner.name];
        
        [self.restart_game_button setAttributedTitle:[RollViewController outlineString:self.restart_game_button.currentTitle] forState:UIControlStateNormal];

        [self.next_turn_button removeFromSuperview];
    }
    
    [self displayDiceOnLoad:YES];

}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [UIView animateWithDuration:1.0 animations:^{
        [self displayDiceOnLoad:NO];
    }];
    
}





#pragma -mark DISPLAY DICE
-(NSInteger)xForDice:(NSInteger)index {
    
    NSInteger total_dice_width = 0;
    for (Dice *dice in self.game.dice) {
                total_dice_width += DICE_SIZE + 4;
    }
    NSInteger first_x = (self.view.frame.size.width - total_dice_width)/2;
    
    return first_x + (DICE_SIZE + 4)*index;
}

-(void)displayDiceOnLoad:(BOOL)on_load {
    for (int i=0; i<NUM_DICE; i++) {
        Dice * dice = [self.game.dice objectAtIndex:i];
        NSInteger x = [self xForDice:i];
        NSInteger y = self.dice_table_view.frame.size.height/2 - DICE_SIZE*2;
        if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            y -= DICE_SIZE;
            self.truth_announcement.textColor = [UIColor blackColor];
            self.losing_player_announcement.textColor = [UIColor blackColor];
        } else {
            self.truth_announcement.textColor = [UIColor lightGrayColor];
            self.losing_player_announcement.textColor = [UIColor lightGrayColor];
        }
        
        CGRect rect = CGRectMake(x, y, DICE_SIZE, DICE_SIZE);
        
        if (on_load) {
            DieView *view = [[DieView alloc] initWithFrame:rect];
            dice.view = view;
            view.value = [dice getValueString];
            [self.dice_table_view addSubview:view];
        } else {
            dice.view.frame = rect;
        }
       
    }
}


#pragma -mark ALERTS
- (IBAction)newGame {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:/*@"New Game"*/@"Nueva Partida"
                                                    message: @"Quieres jugar de nuevo con los mismos jugadores?"//@"Do you want to play with the same players?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:/*@"Yes"*/@"Sí", nil];
    [alert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:/*@"Yes"*/@"Sí"]) {
        [self performSegueWithIdentifier:@"next_turn" sender:self];
        [self.game restartGame];
    } else if([title isEqualToString:@"No"]) {
        [self performSegueWithIdentifier:@"new_game" sender:self];
    }
}



#pragma -mark HANDLING SEGUES
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"next_turn"]) {
        RollViewController *destination_controller = (RollViewController*) segue.destinationViewController;
        [self.game newTurn];
        destination_controller.game = self.game;
    }
}

@end
