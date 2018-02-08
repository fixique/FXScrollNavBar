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

@end

@implementation FXScrollingNavigationController

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldScrollWhenContentFits = NO;
        _expandOnActive = YES;
        _scrollingEnable = YES;
        _navBarSubscribers = @[];
        _scrollableView = nil;
        _prevNavBarState = FXNavBarExpanded;
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
            expandDirection:(FXNavigationBarTransitonalDirection)expandDirection
                subscribers:(NSArray<UIView *>*)subscribers {
    self.scrollableView = scrollableView;
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesuterHandle)];
    self.gestureRecognizer.maximumNumberOfTouches = 1;
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

@end
