//
//  RollViewController.m
//  Mentirosa
//
//  Created by Santiago Seira on 11/25/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import "RollViewController.h"
#import "Dice.h"
#import "DieView.h"
#import "ChooseLieViewController.h"
#import "DecisionViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface RollViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *dice_table_view;
@property (weak, nonatomic) IBOutlet UILabel *lie_announcement;
@property (weak, nonatomic) IBOutlet UIButton *make_claim_button;
@property (weak, nonatomic) IBOutlet UILabel *believed_lie_announcement;
@property (weak, nonatomic) IBOutlet UIButton *done_button;
@property (weak, nonatomic) IBOutlet UIButton *choose_lie_button;
@property (weak, nonatomic) IBOutlet UILabel *shake_to_roll_announcement;
@property (strong, nonatomic) UIView *hidden_dice_area;
@property (strong, nonatomic) UILabel *hidden_dice_label;
@property (nonatomic) BOOL have_rolled;
@property (weak, nonatomic) IBOutlet UIImageView *cubilete;

@end

@implementation RollViewController

-(BOOL)show_hidden_dice {
    return YES;
}

-(UIView*)hidden_dice_area {
    if (!_hidden_dice_area) {
        UIView *hidden_dice_area = [[UIView alloc] init];
        hidden_dice_area.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [hidden_dice_area setUserInteractionEnabled:YES];
        [self.dice_table_view addSubview:hidden_dice_area];
        _hidden_dice_area = hidden_dice_area;
    }
    return _hidden_dice_area;
}

-(UILabel *)hidden_dice_label {
    if (!_hidden_dice_label) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"Dados escondidos";//@"Hidden dice";
        label.font =[UIFont fontWithName:@"Avenir Next" size:15];
        _hidden_dice_label = label;
        [self.hidden_dice_area addSubview:label];
    }
    return _hidden_dice_label;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [[self navigationController] setNavigationBarHidden:NO];

    if (self.game.current_turn.lives_left > 1) {
        self.title = [NSString stringWithFormat:/*@"%@, %ld lives"*/@"%@, %ld vidas", self.game.current_turn.name, (long)self.game.current_turn.lives_left];
    } else {
        self.title = [NSString stringWithFormat:/*@"%@, %ld life"*/@"%@, %ld vida", self.game.current_turn.name, (long)self.game.current_turn.lives_left];
    }
    
    if (self.show_hidden_dice) {
        [self.choose_lie_button setAttributedTitle:[self.class outlineString:self.choose_lie_button.currentTitle] forState:UIControlStateNormal];
    }
    
    if (self.game.lowest_possible_section > 0
        || self.game.lowest_possible_index > 0) {
        [self displayPublicDiceAndHidden:self.show_hidden_dice OnLoad:YES FromCubilete:NO];
    
        self.believed_lie_announcement.text = [NSString stringWithFormat:/*@"Believed: %@" */@"Creíste: %@", [Game prettyfyRoll:self.believed_lie_string] ];
    } else {
        self.choose_lie_button.hidden = YES;
    }
    self.done_button.hidden = YES;
    self.done_button.titleLabel.text = [NSString stringWithFormat:/*@"Pass to %@"*/ @"Pasa a %@", self.game.nextPlayer.name];
    self.have_rolled = NO;
    [self.view bringSubviewToFront:self.shake_to_roll_announcement];
}

+(NSMutableAttributedString*) outlineString:(NSString*)string {
    NSMutableAttributedString *outlined_string =
    [[NSMutableAttributedString alloc] initWithString:string];
    [outlined_string setAttributes:@{ NSStrokeWidthAttributeName : @-3,
                                       NSStrokeColorAttributeName : [UIColor blackColor]}
                              range:NSMakeRange(0, [string length])];
    [outlined_string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [string length])];
    return outlined_string;
}


-(void)viewWillAppear:(BOOL)animated {
    [self rearrangeDice];
}

-(void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma -mark HANDLING ORIENTATIONS


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView animateWithDuration:1.0 animations:^{
        [self rearrangeDice];
    }];

}


#pragma -mark DISPLAYING DICE
-(void)rearrangeDice {
        if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            
            if ([(Dice*)[self.game.dice firstObject] value] != -1) {
                [self rearrangeDicePortrait];
            }
        } else {
            
            if ([(Dice*)[self.game.dice firstObject] value] != -1) {
                [self rearrangeDiceLandscape];
            }
        }
}


-(void)roll {
    for (Dice *dice in self.game.dice) {
        [dice roll];
    }
    [self displayPublicDiceAndHidden:YES OnLoad:NO FromCubilete:YES];
}

-(void)removeHiddenDice {
    for (Dice *dice in self.game.dice ) {
        if (dice.hidden) {
            [dice.view removeFromSuperview];
        }
    }
}



-(NSInteger)xForDicePortrait:(NSInteger)index Public:(BOOL)is_public {
    
    NSInteger total_public_dice_width = 0;
    for (Dice *dice in self.game.dice) {
        if (is_public) {
            if (!dice.hidden) {
                total_public_dice_width += DICE_SIZE + 4;
            }
        } else {
            if (dice.hidden) {
                total_public_dice_width += DICE_SIZE + 4;
            }
        }
    }
    NSInteger first_x = (320/*self.dice_table_view.frame.size.width*/ - total_public_dice_width)/2;
    
    return first_x + (DICE_SIZE + 4)*index;
}


-(void)rearrangeDicePortrait {
    CGRect hidden_dice_rect = CGRectMake(self.dice_table_view.frame.origin.x+5, self.dice_table_view.frame.size.height/2 - 15, /*self.dice_table_view.frame.size.width*/320 - 10, 200);
    
    self.hidden_dice_area.frame = hidden_dice_rect;
    
    CGRect hidden_dice_label_rect = CGRectMake(self.hidden_dice_area.frame.origin.x +self.hidden_dice_area.frame.size.width/2 - 60, self.hidden_dice_area.frame.size.height - 25, self.hidden_dice_area.frame.size.width/2, 21);
    
    self.hidden_dice_label.frame = hidden_dice_label_rect;
    if (self.show_hidden_dice) {
        self.lie_announcement.textColor = [UIColor lightGrayColor];
    }
    
    
    
    if (!self.have_rolled) {
        self.shake_to_roll_announcement.text = /*@"Shake to roll bottom dice"*/ @"Agita los dados de abajo";
    }
    
    NSInteger hidden_dice = 0;
    NSInteger public_dice = 0;
    for (Dice *dice in self.game.dice) {
        if (dice.hidden) {
            NSInteger x = [self xForDicePortrait:hidden_dice Public:NO];
            NSInteger y = 200;//self.dice_table_view.frame.size.height - DICE_SIZE*3;
            
            CGRect rect = CGRectMake(x, y, DICE_SIZE, DICE_SIZE);
            dice.view.frame = rect;
            hidden_dice ++;
        } else {
            NSInteger x = [self xForDicePortrait:public_dice Public:YES];
            NSInteger y = 40;
            CGRect rect = CGRectMake(x, y, DICE_SIZE, DICE_SIZE);
            dice.view.frame = rect;
            public_dice++;
        }
        [self.dice_table_view addSubview:dice.view];
    }

}


-(NSInteger)xForDiceLandscape:(NSInteger)index Public:(BOOL)is_public {
    
    if (is_public) {
        if (index % 2 == 0) {
            return /*self.dice_table_view.frame.size.width*/568 - DICE_SIZE*3;
        } else {
            return /*self.dice_table_view.frame.size.width*/568 - DICE_SIZE*2 +5;
        }
    } else {
        if (index % 2 == 0) {
            return DICE_SIZE*2.5;
        } else {
            return DICE_SIZE*3.5 +5;
        }
    }
}

-(void)rearrangeDiceLandscape {
    
    CGRect hidden_dice_rect = CGRectMake(5, 20, /*self.dice_table_view.frame.size.width*/568/2 - 60, self.dice_table_view.frame.size.height - DICE_SIZE*3 - 5);
    
    self.hidden_dice_area.frame = hidden_dice_rect;
    
    CGRect hidden_dice_label_rect = CGRectMake(self.hidden_dice_area.frame.origin.x+90, self.hidden_dice_area.frame.size.height - 22, self.hidden_dice_area.frame.size.width, 21);
    
    self.hidden_dice_label.frame = hidden_dice_label_rect;

    self.lie_announcement.textColor = [UIColor blackColor];

    
    if (!self.have_rolled) {
        self.shake_to_roll_announcement.text = /*@"Shake to roll left dice"*/ @"Agita los dados de la izquierda";
    }
    
    
    NSInteger hidden_dice = 0;
    NSInteger public_dice = 0;
    for (int i=0; i<[self.game.dice count]; i++) {
        Dice *dice = [self.game.dice objectAtIndex:i];
        if (dice.hidden) {
            NSInteger x = [self xForDiceLandscape:hidden_dice Public:NO];
            NSInteger y = DICE_SIZE/2 + (hidden_dice/2)*(DICE_SIZE +4);
            
            CGRect rect = CGRectMake(x, y, DICE_SIZE, DICE_SIZE);
            dice.view.frame = rect;
            hidden_dice ++;
        } else {
            NSInteger x = [self xForDiceLandscape:public_dice Public:YES];
            NSInteger y = DICE_SIZE/2 + (public_dice/2)*(DICE_SIZE +4);
            CGRect rect = CGRectMake(x, y, DICE_SIZE, DICE_SIZE);
            dice.view.frame = rect;
            public_dice++;
        }
        [self.dice_table_view addSubview:dice.view];
    }
}

-(void)flyIn:(DieView *)dice toRect:(CGRect)rect {
    CGPoint center = CGPointMake(rect.origin.x + DICE_SIZE/2, rect.origin.y + DICE_SIZE/2);
    dice.center = center;
}

- (void)displayPublicDiceAndHidden:(BOOL)show_hidden OnLoad:(BOOL)on_load FromCubilete:(BOOL)from_cubilete {
    NSInteger public_dice = 0;
    NSInteger hidden_dice = 0;
    [self removeHiddenDice];
    for (Dice *dice in self.game.dice) {
        if (dice.hidden) {
            CGRect rect = CGRectMake(0, 0, DICE_SIZE, DICE_SIZE);
            
            DieView *view = [[DieView alloc] initWithFrame:rect];
            
            dice.view = view;
            [self.dice_table_view addSubview:view];
            if (show_hidden) {
                view.value = [dice getValueString];
                if (from_cubilete) {
                    view.center = CGPointMake(80, 350);
                    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{[self flyIn:view toRect:rect];}completion:^(BOOL finished) {
                                         [self.cubilete removeFromSuperview];
                                         self.shake_to_roll_announcement.text = [NSString stringWithFormat:@"%@", [Game prettyfyRoll:[self.game rollAnnouncementWithMinValue:nil]]];
                                         self.choose_lie_button.hidden = NO;
                                     }];
                }
                
                if (self.game.lowest_possible_section > 0
                    || self.game.lowest_possible_index > 0) {
                    // dont allow showing dice on first turn
                    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
                    [panRecognizer setMinimumNumberOfTouches:1];
                    [panRecognizer setMaximumNumberOfTouches:1];
                    [view addGestureRecognizer:panRecognizer];
                }
                hidden_dice++;
            } else {
                dice.view.value = @"question_mark_2";
            }
        } else {
            if (on_load) {
               
                CGRect rect = CGRectMake(0, 0, DICE_SIZE, DICE_SIZE);
                
                
                DieView *view = [[DieView alloc] initWithFrame:rect];
                [dice.view removeFromSuperview];
                dice.view = view;
                view.value = [dice getValueString];
                [self.dice_table_view addSubview:view];
                if (show_hidden) {
                    
                    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
                    [panRecognizer setMinimumNumberOfTouches:1];
                    [panRecognizer setMaximumNumberOfTouches:1];
                    [view addGestureRecognizer:panRecognizer];
                }
                public_dice++;
            }
        }
    }
    [self rearrangeDice];
}





#pragma -mark MOTION GESTURES

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self shakeCubilete];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
    {
        // User was shaking the device. Post a notification named "shake."
        if (!self.have_rolled) {
            [self roll];
            self.have_rolled = YES;
        }
    }
}


-(BOOL)diceInPublicTable:(UIView*)dice {
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        NSInteger y = dice.frame.origin.y;
        NSInteger height = self.dice_table_view.frame.size.height/2;
        if (y > 0
            && y < height) {
            //public
            return YES;
        }
        //private
        return NO;
    } else {
        NSInteger x = dice.frame.origin.x;
        NSInteger width = self.dice_table_view.frame.size.width/2;
        if (x > 0
            && x < width) {
            // private
            return NO;
        }
        //public
        return YES;
    }
}

-(void)move:(UIPanGestureRecognizer*)sender {
    [self.view bringSubviewToFront:sender.view];

    if ((sender.state == UIGestureRecognizerStateChanged) ||
        (sender.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [sender translationInView:self.view];
        
        // make sure dice stay in table_view
        NSInteger x = sender.view.frame.origin.x+translation.x;
        NSInteger y = sender.view.frame.origin.y+translation.y;
        
        if (y > self.dice_table_view.frame.size.height - DICE_SIZE) {
            y = self.dice_table_view.frame.size.height - DICE_SIZE;
        } else if (y < 0) {
            y = 1;
        }
        
        if (x > self.dice_table_view.frame.size.width - DICE_SIZE) {
            x = self.dice_table_view.frame.size.width - DICE_SIZE;
        } else if (x < 0) {
            x = 1;
        }
        
        sender.view.frame = CGRectMake(x, y, sender.view.frame.size.width, sender.view.frame.size.height);
        [sender setTranslation:CGPointZero inView:self.view];
    }
    
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        for (Dice *dice in self.game.dice ) {
            if ([dice.view isEqual:(sender.view)]) {
                
                if ([self diceInPublicTable:sender.view]) {
                    // make dice public
                    dice.hidden = FALSE;
                    
                    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                        NSInteger min_height = self.dice_table_view.frame.size.height/2 - DICE_SIZE*1.5;
                        
                        if (dice.view.frame.origin.y > min_height) {
                            sender.view.frame = CGRectMake(sender.view.frame.origin.x, min_height, sender.view.frame.size.width, sender.view.frame.size.height);
                            
                            [sender setTranslation:CGPointZero inView:self.view];
                        }
                        
                    } else {
                        NSInteger min_width = self.dice_table_view.frame.size.width/2 + DICE_SIZE*2;
                        
                        if (dice.view.frame.origin.x < min_width) {
                            sender.view.frame = CGRectMake(min_width, sender.view.frame.origin.y, sender.view.frame.size.width, sender.view.frame.size.height);
                            
                            [sender setTranslation:CGPointZero inView:self.view];
                        }
                    }

                } else {
                    //make dice hidden
                    dice.hidden = TRUE;
                    
                    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                        NSInteger max_height = self.dice_table_view.frame.size.height/2 + DICE_SIZE;
                        if (dice.view.frame.origin.y < max_height) {
                            sender.view.frame = CGRectMake(sender.view.frame.origin.x, max_height, sender.view.frame.size.width, sender.view.frame.size.height);
                            
                            [sender setTranslation:CGPointZero inView:self.view];
                        }
                        
                    } else {                        
                        NSInteger max_width = self.dice_table_view.frame.size.width/2 - DICE_SIZE*2;
                        if (dice.view.frame.origin.x > max_width) {
                            sender.view.frame = CGRectMake(max_width, sender.view.frame.origin.y, sender.view.frame.size.width, sender.view.frame.size.height);
                            
                            [sender setTranslation:CGPointZero inView:self.view];
                        }
                    }
                }
            }
        }
    }
}


#pragma -mark SHAKE CUBILETE

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

-(void)shakeCubilete {
    CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-20.0));
    CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(20.0));
    
    self.cubilete.transform = leftWobble;  // starting point
    [UIView beginAnimations:@"wobble" context:nil];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:3];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(wobbleEnded:finished:context:)];
    
    self.cubilete.transform = rightWobble; // end here & auto-reverse
    
    [UIView commitAnimations];
    

}

- (void) wobbleEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([finished boolValue]) {
        [UIView beginAnimations:@"wobble" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:2.3];
        [UIView setAnimationDelegate:self];
        self.cubilete.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(20.0));
        [UIView commitAnimations];
    }
}





#pragma -mark ALERTS
- (IBAction)endGame {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:/*@"Warning" */@"Atención"
                                                    message: /*@"Are you sure you want to end the game?"*/@"Seguro que quieres terminar este juego?"
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:/*@"End game"*/@"Terminar juego", nil];
    [alert show];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:/*@"End game"*/@"Terminar juego"]) {
       [self performSegueWithIdentifier:@"end_game" sender:self];
    }
}



#pragma -mark HANDLING SEGUES
- (IBAction)choseLie:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"lie_chosen"]) {
        self.lie_announcement.text = [NSString stringWithFormat:/*@"Claim: %@"*/@"Mentira: %@",[Game prettyfyRoll: self.chosen_lie_string]];
        
        self.done_button.hidden = FALSE;

        [self.done_button setAttributedTitle:[self.class outlineString:[NSString stringWithFormat:/*@"Pass to %@"*/@"Pasa a %@", self.game.nextPlayer.name]] forState:UIControlStateNormal];
    }
    
    [self rearrangeDice];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"choose_lie"]) {
        
        UINavigationController *navigation_controller = (UINavigationController*)segue.destinationViewController;
        ChooseLieViewController *choose_lie_TVC = (ChooseLieViewController*)[navigation_controller.viewControllers firstObject];
        
        choose_lie_TVC.possible_lies = self.game.value_array;
        choose_lie_TVC.lie_to_beat_string = self.believed_lie_string;
        choose_lie_TVC.game = self.game;
        
    } else if ([segue.identifier isEqualToString:@"done"]) {
        DecisionViewController *decision_view_controller = (DecisionViewController*)segue.destinationViewController;
        
        self.game.current_turn = [self.game nextPlayer];
        self.game.lowest_possible_section = self.chosen_lie_section;
        self.game.lowest_possible_index = self.chosen_lie_index;
        
        if (self.game.lowest_possible_section == [self.game.value_array count]) {
            // chose AAAAA
            // -> there is no decision... must not believe
        } else {
            [self.game adjustValueArray];
        }
        
        
        decision_view_controller.lie_string = self.chosen_lie_string;
        decision_view_controller.game = self.game;
    } else if ([segue.identifier isEqualToString:@"end_game"]) {
        
        self.game = nil;
    }
}


@end
