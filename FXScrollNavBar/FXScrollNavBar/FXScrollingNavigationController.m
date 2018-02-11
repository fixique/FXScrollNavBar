//
//  FXScrollingNavigationController.m
//  FXScrollNavBar
//
//  Created by Vlad Krupenko on 08.02.2018.
//  Copyright © 2018 Vladislav Krupenko. All rights reserved.
//

#import "FXScrollingNavigationController.h"

@interface FXScrollingNavigationController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *scrollableView;
@property (nonatomic) FXNavigationBarState navBarState;
@property (nonatomic) FXNavigationBarState prevNavBarState;
@property (nonatomic) CGFloat delayDistance;
@property (nonatomic) CGFloat maxDelay;
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) CGFloat scrollSpeedFactor;
@property (nonatomic) CGFloat collapseDirectionFactor;

@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) CGFloat deltaLimit;
@property (nonatomic) CGFloat navBarHeight;
@property (nonatomic) CGFloat statusBarHeight;
@property (nonatomic) CGFloat extendedStatusBarDifference;
@property (nonatomic) CGFloat fullNavBarHeight;
@end

@implementation FXScrollingNavigationController

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldScrollWhenContentFits = NO;
        _expandOnActive = YES;
        _scrollingEnable = YES;
        _scrollableView = nil;
        _prevNavBarState = FXNavBarVisible;
        _delayDistance = 0.0;
        _maxDelay = 0.0;
        _lastContentOffset = 0.0;
        _scrollSpeedFactor = 1.0;
        _collapseDirectionFactor = 1.0;
    }
    return self;
}

#pragma mark - Public

- (void)subscribeScrollView:(UIView *)scrollableView
                      delay:(CGFloat)delay
          scrollSpeedFactor:(CGFloat)scrollSpeedFactor
            expandDirection:(FXNavigationBarTransitonalDirection)expandDirection {
    self.scrollableView = scrollableView;
    self.maxDelay = delay;
    self.delayDistance = delay;
    self.scrollingEnable = YES;
    self.scrollSpeedFactor = scrollSpeedFactor;
    self.collapseDirectionFactor = expandDirection;
    
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesuterHandle)];
    self.gestureRecognizer.maximumNumberOfTouches = 1;
    self.gestureRecognizer.delegate = self;
    [self.scrollableView addGestureRecognizer:self.gestureRecognizer];
    
    [self registerNotifications];
}

- (void)hideNavBarAnimated:(BOOL)animated withDuration:(NSTimeInterval)duration {
    if (!self.scrollableView && !self.visibleViewController) {
        return;
    }
    
    if (self.navBarState == FXNavBarVisible) {
        self.navBarState = FXNavBarTransitional;
        [UIView animateWithDuration:animated ? duration : 0 animations:^{
            [self scrollWithDelta:self.fullNavBarHeight ignoreDelay:NO];
            [self.visibleViewController.view setNeedsLayout];
            if (self.navigationBar.isTranslucent) {
                CGPoint currentOffset = self.contentOffset;
                [self convertScrollabelView].contentOffset = CGPointMake(currentOffset.x, currentOffset.y + self.navBarHeight);
            }
        } completion:^(BOOL finished) {
            self.navBarState = FXNavBarHide;
        }];
    } else {
        [self updateNavBarAlpha];
    }
}



#pragma mark - Private

- (void)scrollWithDelta:(CGFloat)delta ignoreDelay:(BOOL)ignoreDelay {
    CGFloat scrollDelta = delta;
    CGRect frame = self.navigationBar.frame;
    
    // Scrolling up. Hide navbar
    if (scrollDelta > 0) {
        if (!ignoreDelay) {
            self.delayDistance -= scrollDelta;
            if (self.delayDistance > 0) {
                return;
            }
        }
        
        if (!self.shouldScrollWhenContentFits && self.navBarState != FXNavBarHide && self.scrollableView.frame.size.height >= self.contentSize.height) {
            return;
        }
        
        if (frame.origin.y - scrollDelta < -self.deltaLimit) {
            scrollDelta = frame.origin.y + self.deltaLimit;
        }
        
        if (frame.origin.y <= -self.deltaLimit) {
            self.navBarState = FXNavBarHide;
            self.delayDistance = self.maxDelay;
        } else {
            self.navBarState = FXNavBarTransitional;
        }
    }
    
    if (scrollDelta < 0) {
        if (!ignoreDelay) {
            self.delayDistance += scrollDelta;
            
            if (self.delayDistance > 0 && self.maxDelay < self.contentOffset.y) {
                return;
            }
        }
        
        if (frame.origin.y - scrollDelta > self.statusBarHeight) {
            scrollDelta = frame.origin.y - self.statusBarHeight;
        }
        
        if (frame.origin.y >= self.statusBarHeight) {
            self.navBarState = FXNavBarVisible;
            self.delayDistance = self.maxDelay;
        } else {
            self.navBarState = FXNavBarTransitional;
        }
    }
    
    //TODO: Make update
    [self updateNavBarSizeWithDelta:delta];
    [self updateNavBarAlpha];
    [self restoreContentOffsetWithDelta:delta];
}

#pragma mark - Updates

- (void)updateNavBarSizeWithDelta:(CGFloat)delta {
    CGRect navBarFrame = self.navigationBar.frame;
    
    // Перемещаем навбар
    navBarFrame.origin = CGPointMake(navBarFrame.origin.x, navBarFrame.origin.y - delta);
    self.navigationBar.frame = navBarFrame;
    
    if (!self.navigationBar.isTranslucent) {
        CGFloat navBarY = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
        CGRect topViewControllerFrame = self.topViewController ? self.topViewController.view.frame : CGRectZero;
        topViewControllerFrame.origin = CGPointMake(topViewControllerFrame.origin.x, navBarY);
        topViewControllerFrame.size = CGSizeMake(topViewControllerFrame.size.width, self.view.frame.size.height - (navBarY) - [self getTabBarOffset]);
        self.topViewController.view.frame = topViewControllerFrame;
    }
}

- (void)restoreContentOffsetWithDelta:(CGFloat)delta {
    if (self.navigationBar.isTranslucent || delta == 0) {
        return;
    }
    
    UIScrollView *scrollView = [self convertScrollabelView];
    [scrollView setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - delta)];
}

- (void)updateNavBarAlpha {
    CGRect navBarFrame = self.navigationBar.frame;
    CGFloat alpha = (navBarFrame.origin.y + self.deltaLimit) / navBarFrame.size.height;
    
    self.topViewController.navigationItem.titleView.alpha = alpha;
    self.navigationBar.tintColor = [self.navigationBar.tintColor colorWithAlphaComponent:alpha];

    UIColor *titleColor = self.navigationBar.titleTextAttributes[NSForegroundColorAttributeName];
    if (titleColor) {
        NSMutableDictionary *titleTextAttributes = [self.navigationBar.titleTextAttributes mutableCopy];
        titleTextAttributes[NSForegroundColorAttributeName] = [titleColor colorWithAlphaComponent:alpha];
        [self.navigationBar setTitleTextAttributes:titleTextAttributes];
    } else {
        NSMutableDictionary *titleTextAttributes = [self.navigationBar.titleTextAttributes mutableCopy];
        titleTextAttributes[NSForegroundColorAttributeName] = [[UIColor blackColor] colorWithAlphaComponent:alpha];
        [self.navigationBar setTitleTextAttributes:titleTextAttributes];
    }
    
    for (UIView *subview in self.navigationBar.subviews) {
        if ([self shouldHideView:subview]) {
            [self setAlphaOfSubview:subview withAlpha:alpha];
        }
    }
    
    self.topViewController.navigationItem.leftBarButtonItem.customView.alpha = alpha;
    for (UIView *subview in self.topViewController.navigationItem.leftBarButtonItems) {
        subview.alpha = alpha;
    }
    
    self.topViewController.navigationItem.rightBarButtonItem.customView.alpha = alpha;
    for (UIView *subview in self.topViewController.navigationItem.rightBarButtonItems) {
        subview.alpha = alpha;
    }
}

#pragma mark - Getters and Setters

- (void)setNavBarState:(FXNavigationBarState)navBarState {
    _navBarState = navBarState;
}

- (FXNavigationBarState)getNavBarState {
    return _navBarState;
}

#pragma mark -

- (void)panGesuterHandle {
    
}

#pragma mark - Notifications

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDidRotate)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)didBecomeActive {
    
}

- (void)willResignActive {
    
}

- (void)deviceDidRotate {
    
}

#pragma mark - Size Helpers

- (CGFloat)navBarHeight {
    return self.navigationBar.frame.size.height;
}

- (CGFloat)statusBarHeight {
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (@available(iOS 11.0, *)) {
        statusBarHeight = MAX([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].delegate.window.safeAreaInsets.top);
    }
    return statusBarHeight - self.extendedStatusBarDifference;
}

- (CGFloat)extendedStatusBarDifference {
    return fabs(self.view.bounds.size.height - ([UIApplication sharedApplication].delegate.window ? [UIApplication sharedApplication].delegate.window.frame.size.height : [UIScreen mainScreen].bounds.size.height));
}

- (CGSize)contentSize {
    if (!self.scrollableView) {
        return CGSizeZero;
    }
    
    UIScrollView *scrollView = (UIScrollView *)self.scrollableView;
    CGFloat verticalInset = scrollView.contentInset.top + scrollView.contentInset.bottom;
    return CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + verticalInset);
}

- (CGPoint)contentOffset {
    return [self convertScrollabelView].contentOffset;
}

- (CGFloat)deltaLimit {
    return self.navBarHeight - self.statusBarHeight;
}

- (CGFloat)getTabBarOffset {
    if (self.tabBarController) {
        return self.tabBarController.tabBar.isTranslucent ? 0 : self.tabBarController.tabBar.frame.size.height;
    }
    return 0;
}

- (CGFloat)fullNavBarHeight {
    return self.navBarHeight + self.statusBarHeight;
}

#pragma mark - Helpers

- (UIScrollView *)convertScrollabelView {
    if ([self.scrollableView isKindOfClass:[UIWebView class]]) {
        return (UIScrollView *)self.scrollableView;
    } else {
        return (UIScrollView *)self.scrollableView;
    }
}

- (BOOL)shouldHideView:(UIView *)view {
    NSString *className = [[view.classForCoder description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSMutableArray *viewNames = [@[@"UINavigationButton", @"UINavigationItemView", @"UIImageView", @"UISegmentedControl"] mutableCopy];
    if (@available(iOS 11.0, *)) {
        [viewNames addObject:(self.navigationBar.prefersLargeTitles ? @"UINavigationBarLargeTitleView" : @"UINavigationBarContentView")];
    } else {
        [viewNames addObject:@"UINavigationBarContentView"];
    }
    return [viewNames containsObject:className];
}

- (void)setAlphaOfSubview:(UIView *)view withAlpha:(CGFloat)alpha {
    view.alpha = alpha;
    for (UIView *item in view.subviews) {
        item.alpha = alpha;
    }
}

@end
