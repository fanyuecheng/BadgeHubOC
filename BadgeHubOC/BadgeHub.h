//
//  BadgeHub.h
//  BadgeHubOC
//
//  Created by 月成 on 2020/2/28.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BadgeView : UIView

@property (nonatomic, assign) BOOL isUserChangingBackgroundColor;

@end

@interface BadgeHub : NSObject

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger maxCount;

- (instancetype)initWithView:(__kindof UIView *)view;
- (void)setCircleAtFrame:(CGRect)frame;
- (void)setCircleColor:(UIColor *)circleColor
            labelColor:(UIColor *)labelColor;
- (void)setCircleBorderColor:(UIColor *)color
                 borderWidth:(CGFloat)width;
- (void)moveCircleByX:(CGFloat)x
                    y:(CGFloat)y;
- (void)scaleCircleSizeByScale:(CGFloat)scale;
- (void)increment;
- (void)incrementBy:(NSInteger)amount;
- (void)decrement;
- (void)decrementBy:(NSInteger)amount;
- (void)hideCount;
- (void)showCount;
- (void)setCountLabelFont:(UIFont *)font;

- (void)pop;
- (void)blink;
- (void)bump;

@end

NS_ASSUME_NONNULL_END
