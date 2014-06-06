//
//  ChooseLieViewController.m
//  Mentirosa
//
//  Created by Santiago Seira on 12/5/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import "ChooseLieViewController.h"
#import "Game.h"
#import "RollViewController.h"
#import "DieView.h"
#import "Dice.h"
@interface ChooseLieViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *dice_table_view;
@end

@implementation ChooseLieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *lie_to_beat_announcement;
    if ([self.lie_to_beat_string length]) {
        lie_to_beat_announcement = [NSString stringWithFormat:/*@"Believed: %@"*/@"Creíste: %@", [Game prettyfyRoll:self.lie_to_beat_string]];
    } else {
        lie_to_beat_announcement = @"Escoge una mentira";//@"Choose a claim";
    }
    self.lie_to_beat.text = lie_to_beat_announcement;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.table_view setContentOffset:CGPointMake(0, 0)];
}

-(void)viewDidAppear:(BOOL)animated {
    [self displayDice];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.possible_lies count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.possible_lies[section] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self titleForSection:section];
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, self.dice_table_view.frame.size.width, 23);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = title;
    label.backgroundColor = [UIColor darkGrayColor];
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.dice_table_view.frame.size.width, 23)];
    [view addSubview:label];
    [label setCenter:view.center];

    
    return view;
}



- (NSString*)titleForSection:(NSInteger)section {
    if (section == [self.possible_lies count] - 1) {
        return @"Quintilla";
        // return @"5 of a kind";
    } else if (section == [self.possible_lies count] - 2) {
        return @"Poker";
    } else if (section == [self.possible_lies count] - 3) {
         return @"Full House";
    } else if (section == [self.possible_lies count] - 4) {
        return @"Tercia";
//         return @"3 of a kind";
    } else if (section == [self.possible_lies count] - 5) {
        return @"2 Pares";
//         return @"2 pairs";
    } else {
        return @"Par";
//         return @"Pair";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell_identifier = @"lie";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lie"];
    }
    
    NSString *lie = self.possible_lies[indexPath.section][indexPath.row];
    
    cell.textLabel.text = [Game prettyfyLie:lie];
    [cell.textLabel setTextColor:[UIColor lightGrayColor]];

    cell.imageView.layer.cornerRadius = 4;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.image = [UIImage imageNamed:[lie substringToIndex:1]];
                        
    return cell;
}

#pragma -mark DISPLAY DICE


-(NSInteger)xForDice:(NSInteger)index {
    
    NSInteger total_dice_width = 0;
    for (Dice *dice in self.game.dice) {
        total_dice_width += DICE_SIZE + 4;
    }
    NSInteger first_x = (self.dice_table_view.frame.size.width - total_dice_width)/2;
    
    return first_x + (DICE_SIZE + 4)*index;
}


-(void)displayDice {
    [UIView animateWithDuration:.7 animations:^{
        for (int i=0; i<[self.game.dice count]; i++) {
            Dice * dice = [self.game.dice objectAtIndex:i];
            
            NSInteger x = [self xForDice:i];
            
            NSInteger y = 25;
            
            CGRect rect = CGRectMake(x, y, DICE_SIZE, DICE_SIZE);
            
            dice.view.frame = rect;
            [self.dice_table_view addSubview:dice.view];
        }
    }];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self displayDice];
    [self.table_view reloadData];
  
}

#pragma mark - Navigation
- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"lie_chosen"]) {
        RollViewController *roll_view_controller = (RollViewController*)segue.destinationViewController;
        NSIndexPath *indexPath = [self.table_view indexPathForSelectedRow];
        
        roll_view_controller.chosen_lie_string = self.possible_lies[indexPath.section][indexPath.row];
        if (indexPath.row + 1 == [self.possible_lies[indexPath.section] count]) {
            roll_view_controller.chosen_lie_section = indexPath.section + 1;
            roll_view_controller.chosen_lie_index = 0;
        } else {
            roll_view_controller.chosen_lie_section = indexPath.section;
            roll_view_controller.chosen_lie_index = indexPath.row + 1;
        }
    }
}
@end
