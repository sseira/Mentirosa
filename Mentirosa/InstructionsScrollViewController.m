//
//  InstructionsScrollViewController.m
//  Mentirosa
//
//  Created by Santiago Seira on 12/11/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import "InstructionsScrollViewController.h"
#import "Dice.h"
#import "DieView.h"
#import "Game.h"
@interface InstructionsScrollViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) UITableView *rankings;
@end

@implementation InstructionsScrollViewController

#define MARGIN 20
#define FULL_WIDTH 280

-(UITableView *)rankings {
    if (!_rankings) {
        UITableView *rankings = [[UITableView alloc] initWithFrame:CGRectMake(0, 1720, FULL_WIDTH + 2*MARGIN, 430)];
        
        rankings.delegate = self;
        rankings.dataSource = self;
        rankings.backgroundColor = [UIColor darkGrayColor];
        _rankings = rankings;
    }
    return _rankings;
}

-(IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//to take out after eliminating navigation controller
-(BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad
{
    self.title = @"Instructions";
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"< Back"
                                             style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(back:)];
    
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    UIScrollView *scrollView_real =[[UIScrollView alloc] initWithFrame:fullScreenRect];
    scrollView_real.contentSize=CGSizeMake(320,2150);

    scrollView_real.backgroundColor = [UIColor lightGrayColor];
    
    UIImageView *scrollView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 2150)];
    
    
    
    CGRect game_intro_rect = CGRectMake(MARGIN, 55, FULL_WIDTH, 55  );
    NSString *game_intro = @"This is a game of luck, wits, but most of all this is a game of deception.";
    
    CGRect cubilete_intro_rect = CGRectMake(MARGIN, 135, 200, 65  );
    NSString *cubilete_intro = @"The game starts with a player rolling 5 dice in the 'cubilete' .";
    
    CGRect cubilete_rect = CGRectMake(230, 130, 55, 70);
    
    CGRect dice_label_rect = CGRectMake(MARGIN, 210, FULL_WIDTH, 21);
    
    CGRect instruction_rect_1 = CGRectMake(MARGIN, 315, 130, 100);
    NSString *instruction_1 = @"This roll is private and no other players can see what he has rolled.  ";
    
    CGRect first_roll_image_rect = CGRectMake(155, 295, 140, 140);
    
    NSString *instruction_2 = @"He then must make a claim to the next player concerning the value of the dice he has rolled. The player next to him must then decide whether he is telling the truth or not.";
    CGRect instruction_rect_2 = CGRectMake(MARGIN, 440, FULL_WIDTH, 100);
    
    
    
    
    CGRect believes_rect = CGRectMake(MARGIN, 550, FULL_WIDTH, 21);
    CGRect believes_image_rect = CGRectMake(90, 580, 200, 280);
    NSString *instruction_believe = @"He is allowed to see all of the dice that were rolled and is now responsible for making a new claim of higher value to send to the player after him. \nHe is allowed to reroll any of the dice he wants, and move the other dice out onto the table for everyone to see publicly.\n (He can also choose to not reroll any dice and solely pass on a higher claim, hinting that the previous player undersold their roll value)";
    CGRect instruction_believe_rect = CGRectMake(MARGIN, 865, FULL_WIDTH, 200);
    
    
    CGRect not_believes_rect = CGRectMake(MARGIN, 1075, FULL_WIDTH, 21);
    CGRect not_believes_image_rect = CGRectMake(90, 1100, 200, 280);
    NSString *instruction_not_believe = @"All of the dice are revealed to the public.\n\t-> if the dice rolled represent a lower value than was claimed, then player 1 looses a life for getting caught lying.\n\t-> if the dice rolled represent a higher or equal value than was claimed, then player 2 looses a life for not believing a true claim\nThe player who lost a life starts a new turn by re-rolling all of the dice.\n(if a player gets eliminated the player that eliminated him starts next turn);";
    CGRect instruction_not_believe_rect = CGRectMake(MARGIN, 1400, FULL_WIDTH, 230);
    
    CGRect win_label_rect = CGRectMake(55, 1640, 250, 21);
    
    //CGRect dice_ranking_label_rect = CGRectMake(55, 1680, 250, 21);

    
    
    
    // add a view, or views, as a subview of the scroll view.
    [scrollView addSubview:[self addTitle]];
    [scrollView addSubview:[self addInstruction: game_intro withRect:game_intro_rect]];
    [scrollView addSubview:[self addInstruction: cubilete_intro withRect:cubilete_intro_rect]];
    [scrollView addSubview:[self addImageNamed:@"cubilete" withRect:cubilete_rect]];
    
    [scrollView addSubview:[self addLabel:@"The faces of the dice:" withRect:dice_label_rect]];
    [scrollView addSubview:[self addDiceView]];
    [scrollView addSubview:[self addInstruction: instruction_1 withRect:instruction_rect_1]];
    [scrollView addSubview:[self addImageNamed:@"first_roll" withRect:first_roll_image_rect]];

    [scrollView addSubview:[self addInstruction: instruction_2 withRect:instruction_rect_2]];
    
    
    [scrollView addSubview:[self addLabel:@"If he believes:" withRect:believes_rect]];
    [scrollView addSubview:[self addImageNamed:@"did believe" withRect:believes_image_rect]];
    [scrollView addSubview:[self addInstruction: instruction_believe withRect:instruction_believe_rect]];

    [scrollView addSubview:[self addLabel:@"If he doesnt believe:" withRect:not_believes_rect]];
    [scrollView addSubview:[self addImageNamed:@"did not believe" withRect:not_believes_image_rect]];
    [scrollView addSubview:[self addInstruction: instruction_not_believe withRect:instruction_not_believe_rect]];
    
    [scrollView addSubview:[self addLabel:@"Last player standing wins!" withRect:win_label_rect]];
    
    [scrollView addSubview:[self addRankingTitle]];
    
    [scrollView addSubview:self.rankings];
    
    
    [scrollView_real addSubview:scrollView];
    
    scrollView.image = [UIImage imageNamed:@"green"];
    scrollView.userInteractionEnabled = YES;
    self.view=scrollView_real;
	// Do any additional setup after loading the view.
}


#pragma mark - add Divs
-(UILabel *) addRankingTitle{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, 1680, FULL_WIDTH, 21)];
    title.text = @"Dice Roll Rankings by Value";
    [title setFont:[UIFont fontWithName:@"Avenir Next" size:20]];
    [title setTextColor:[UIColor blackColor]];
    title.textAlignment = NSTextAlignmentCenter;
    return title;
}

-(UILabel *)addTitle {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, 0, FULL_WIDTH, 55)];
    title.text = @"MENTIROSA";
    [title setFont:[UIFont fontWithName:@"Hiragino Mincho ProN W6" size:24]];
    [title setTextColor:[UIColor blackColor]];
    title.textAlignment = NSTextAlignmentCenter;
    return title;
}

-(UITextView*)addInstruction:(NSString*)instruction withRect:(CGRect)rect {
    UITextView *description = [[UITextView alloc] initWithFrame:rect];
    description.text = instruction;
    [description setFont:[UIFont fontWithName:@"Avenir Next" size:13]];
    description.backgroundColor = [UIColor colorWithWhite:1 alpha:.4];
    description.editable = NO;
    description.selectable = NO;
    return description;
}

-(UIImageView*)addImageNamed:(NSString*)image_name withRect:(CGRect)rect {
    UIImageView *image_view = [[UIImageView alloc] initWithFrame:rect];
    UIImage *image = [UIImage imageNamed:image_name];
    image_view.image = image;
    return image_view;
}

-(UIView*)addDiceView {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(MARGIN, 235, FULL_WIDTH, 70)];
    for (int i=0; i< [[Dice validValues] count] ; i++) {
        DieView *dice_view = [[DieView alloc] init];
        dice_view.value = [[Dice validValues] objectAtIndex:i];
        NSInteger x = i*(DICE_SIZE + 3);
        dice_view.frame = CGRectMake(x, 0, DICE_SIZE, DICE_SIZE);
        [container addSubview:dice_view];
    }
    return container;
}

-(UILabel *)addLabel:(NSString*)text withRect:(CGRect)rect {
    UILabel *title = [[UILabel alloc] initWithFrame:rect];
    title.text = text;
    [title setFont:[UIFont fontWithName:@"Avenir Next" size:17]];
    [title setTextColor:[UIColor blackColor]];
    return title;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[Game valueArray] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[Game valueArray][section] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self titleForSection:section];
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, self.rankings.frame.size.width, 23);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = title;
    label.backgroundColor = [UIColor darkGrayColor];
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.rankings.frame.size.width, 23)];
    [view addSubview:label];
    [label setCenter:view.center];
    
    
    return view;
}



- (NSString*)titleForSection:(NSInteger)section {
    if (section == [[Game valueArray] count] - 1) {
        return @"5 of a kind";
    } else if (section == [[Game valueArray] count] - 2) {
        return @"Poker";
    } else if (section == [[Game valueArray] count] - 3) {
        return @"Full House";
    } else if (section == [[Game valueArray] count] - 4) {
        return @"3 of a Kind";
    } else if (section == [[Game valueArray] count] - 5) {
        return @"2 Pairs";
    } else {
        return @"Pair";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell_identifier = @"lie";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lie"];
    }
    
    NSString *lie = [Game valueArray][indexPath.section][indexPath.row];
    
    cell.textLabel.text = [Game prettyfyLie:lie];
    [cell.textLabel setTextColor:[UIColor lightGrayColor]];
    cell.backgroundColor = [UIColor blackColor];
    cell.imageView.layer.cornerRadius = 4;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.image = [UIImage imageNamed:[lie substringToIndex:1]];
    
    return cell;
}


@end
