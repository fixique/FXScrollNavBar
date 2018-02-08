//
//  FXScrollingNavigationController.h
//  FXScrollNavBar
//
//  Created by Vlad Krupenko on 08.02.2018.
//  Copyright © 2018 Vladislav Krupenko. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Состояния навигейшен бара
 */
typedef NS_ENUM(NSUInteger, FXNavigationBarState) {
    FXNavBarExpanded,       // Навигейшен бар полностью раскрыт
    FXNavBarVisible,        // Навигейшен бар полностью видим
    FXNavBarTransitional    // Навигейшен бар находится в переходном состояние
};

/**
 *  Направление скролла навигейшен бара
 */
typedef NS_ENUM(NSInteger, FXNavigationBarTransitonalDirection) {
    scrollingUp = -1, // Скроллим вверх
    scrollingDown = 1 // Скроллим вниз
};

@interface FXScrollingNavigationController : UINavigationController

@property (nonatomic) BOOL shouldScrollWhenContentFits;
@property (nonatomic) BOOL expandOnActive;
@property (nonatomic) BOOL scrollingEnable;
@property (nonatomic, strong) NSArray *navBarSubscribers;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecognizer;

#pragma mark - Getters and Setters

- (void)setNavBarState:(FXNavigationBarState)navBarState;
- (FXNavigationBarState)getNavBarState;

@end
