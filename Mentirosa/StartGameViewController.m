//
//  StartGameViewController.m
//  Mentirosa
//
//  Created by Santiago Seira on 11/17/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import "StartGameViewController.h"
#import "RollViewController.h"

@interface StartGameViewController () <UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableArray *player_names;
@property (strong, nonatomic) Game *game;
@property (weak, nonatomic) IBOutlet UITextView *player_names_view;
@property (strong, nonatomic) UIAlertView *add_player_alert;

@end

@implementation StartGameViewController

#pragma -mark SETTERS
-(NSMutableArray *)player_names {
    if (!_player_names) {
        _player_names = [[NSMutableArray alloc] init];
    }
    return _player_names;
}

#pragma -mark ADD PLAYER ALERT
- (IBAction)addPlayer:(UIButton *)sender {

    UIAlertView *add_player_alert = [[UIAlertView alloc] initWithTitle:@"Añadir jugador"//@"Add player"
                                                    message:@"Nombre del jugador"//@"Enter player's name"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancelar"//@"Cancel"
                                          otherButtonTitles:@"Añadir"/*@"Add"*/,nil];
    
    add_player_alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [add_player_alert textFieldAtIndex:0].autocorrectionType = UITextAutocorrectionTypeYes;
    [add_player_alert textFieldAtIndex:0].delegate = self;
    [[add_player_alert textFieldAtIndex:0] setReturnKeyType:UIReturnKeyDone];
    [add_player_alert show];
    self.add_player_alert = add_player_alert;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 10) ? NO : YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Añadir"/*@"Add"*/]) {
          [self addPlayerName:[alertView textFieldAtIndex:0].text];
    }
}

-(void)addPlayerName:(NSString*)name {
    if (![name length]) return;
    
    [self.player_names addObject:name];
    
    NSMutableString * bulletList = [[NSMutableString alloc] init];
    for (NSString *name in self.player_names)
    {
        if ([name isEqual:[self.player_names firstObject]]) {
            [bulletList appendFormat:@"\u2022 %@", name];
            
        } else {
            [bulletList appendFormat:@"\n\u2022 %@", name];
        }
    }
    self.player_names_view.hidden = NO;
    
    if ([self.player_names count] < 6) {
        self.player_names_view.frame = CGRectMake(self.player_names_view.frame.origin.x, self.player_names_view.frame.origin.y, self.player_names_view.frame.size.width, 22*[self.player_names count]);
    }
    
    self.player_names_view.text = bulletList;
    self.player_names_view.font = [UIFont fontWithName:@"Avenir Next" size:15];
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.player_names_view.hidden = YES;
    [self.player_names_view setContentInset:UIEdgeInsetsMake(-6, 0, 6,0)];
    
}


#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; // make "return key" hide keyboard
    //make it accept alert when return is clicked
    [self addPlayerName:[self.add_player_alert textFieldAtIndex:0].text];
    [self.add_player_alert dismissWithClickedButtonIndex:1 animated:YES];
    return YES;
}



- (BOOL)startGame {
    NSMutableArray *players = [[NSMutableArray alloc] init];

    for (NSString *name in self.player_names) {
        Player *player  = [Player initWithName:name];
        [players addObject:player];
    }
    if ([players count] < 2) {
        // no players input popup alert!!
        return NO;
    }
    Game *game = [Game initGameWithPlayers:players];
    self.game = game;
    return YES;
}


#pragma -mark HANDLING SEGUES
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"start_game"]) {
        if ([self startGame]) {
            return YES;
        } else {
            // popup alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Listo para jugar?" //@"Ready to Play?"
                                                            message:@"Añade por lo menos 2 jugadores" //@"Must add at least 2 players"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    } else {
        return YES;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"start_game"]) {
        UINavigationController *nav_controller = (UINavigationController*)segue.destinationViewController;
        
        RollViewController *destination = (RollViewController*)[nav_controller.viewControllers firstObject];
        destination.game = self.game;

    }
}

@end
