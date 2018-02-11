//
//  ViewController.m
//  FXScrollNavBar
//
//  Created by Vlad Krupenko on 08.02.2018.
//  Copyright © 2018 Vladislav Krupenko. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "FXScrollingNavigationController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.93 green:0.3 blue:0.24 alpha:1];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    if ([self.navigationController isKindOfClass:[FXScrollingNavigationController class]]) {
        FXScrollingNavigationController *navCtrl = (FXScrollingNavigationController *)self.navigationController;
        [navCtrl subscribeScrollView:self.tableView delay:0.0 scrollSpeedFactor:1.0 expandDirection:scrollingDown];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.navigationController isKindOfClass:[FXScrollingNavigationController class]]) {
        FXScrollingNavigationController *navCtrl = (FXScrollingNavigationController *)self.navigationController;
        [navCtrl showNavBarAnimated:YES withDuration:animationDurationInterval];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController isKindOfClass:[FXScrollingNavigationController class]]) {
        FXScrollingNavigationController *navCtrl = (FXScrollingNavigationController *)self.navigationController;
        [navCtrl stopSubscribeScrollViewWithShowNavBar:YES];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([self.navigationController isKindOfClass:[FXScrollingNavigationController class]]) {
        FXScrollingNavigationController *navCtrl = (FXScrollingNavigationController *)self.navigationController;
        [navCtrl showNavBarAnimated:YES withDuration:animationDurationInterval];
    }
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"testCell" forIndexPath:indexPath];
    cell.testPublicLabel.text = [NSString stringWithFormat:@"Test text number: %ld", indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}




@end
