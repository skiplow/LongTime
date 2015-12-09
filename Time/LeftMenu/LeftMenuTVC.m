//
//  LeftMenuTVC.m
//  testProject
//
//  Created by artur on 2/14/14.
//  Copyright (c) 2014 artur. All rights reserved.
//

#import "LeftMenuTVC.h"
#import "TimeIndexViewController.h"
#import "ResourceViewController.h"


@interface LeftMenuTVC ()

@end

@implementation LeftMenuTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Initilizing data souce
    self.tableData = [@[@"首页",@"完成库"] mutableCopy];
    //[self.view setBackgroundColor:[UIColor colorWithRed:255/255.0f green:252/255.0f blue:231/255.0f alpha:1.0f]];
    if ([TimeUtils isDayTime]) {
        [self.view setBackgroundColor:[UIColor LTDayYellowBackGround]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor LTNightPurpleBackGround]];
    }

}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.tableData[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:16]];
    
    if(0 == indexPath.row)
    {
        cell.backgroundColor = [UIColor colorWithRed:234/255.0f green:71/255.0f blue:79/255.0f alpha:1.0f];
    }
    else if(1 == indexPath.row)
    {
        cell.backgroundColor = [UIColor colorWithRed:90/255.0f green:58/255.0f blue:77/255.0f alpha:1.0f];
    }
    
    return cell;
}
#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nvc;
    UIViewController *rootVC;
    switch (indexPath.row) {
        case 0:
        {
            rootVC = [[TimeIndexViewController alloc] init];
        }
            break;
        case 1:
        {
            rootVC = [[ResourceViewController alloc] init];
        }
            break;
        
        default:
            break;
    }
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    [self openContentNavigationController:nvc];
}

@end
