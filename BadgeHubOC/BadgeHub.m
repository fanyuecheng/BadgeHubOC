//
//  BadgeHub.m
//  BadgeHubOC
//
//  Created by 月成 on 2020/2/28.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "BadgeHub.h"

static const CGFloat notificHubDefaultDiameter = 30;
static const CGFloat countMagnitudeAdaptationRatio = 0.3;
// Pop values
static const CGFloat popStartRatio = 0.85;
static const CGFloat popOutRatio = 1.05;
static const CGFloat popInRatio = 0.95;
// Blink values
static const CGFloat blinkDuration = 0.1;
static const CGFloat blinkAlpha = 0.1;
// Bump values
static const CGFloat firstBumpDistance = 8.0;
static const CGFloat bumpTimeSeconds = 0.13;
static const CGFloat secondBumpDist = 4.0;
static const CGFloat bumpTimeSeconds2 = 0.1;

@implementation BadgeView

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (self.isUserChangingBackgroundColor) {
        [super setBackgroundColor:backgroundColor];
        self.isUserChangingBackgroundColor = NO;
    }
}

@end

@interface BadgeHub ()

@property (nonatomic, strong) UIView *hubView;
@property (nonatomic, assign) NSInteger curOrderMagnitude;
@property (nonatomic, strong) UILabel   *countLabel;
@property (nonatomic, strong) BadgeView *redCircle;
@property (nonatomic, assign) CGPoint   initialCenter;
@property (nonatomic, assign) CGRect    baseFrame;
@property (nonatomic, assign) CGRect    initialFrame;
@property (nonatomic, assign) BOOL      isIndeterminateMode;
 
@end

@implementation BadgeHub

- (instancetype)initWithView:(__kindof UIView *)view {
    if (self = [super init]) {
        self.maxCount = 100000;
        [self setView:view count:0];
    }
    return self;
}

- (void)setView:(UIView *)view
          count:(NSInteger)count {
    self.curOrderMagnitude = 0;
    CGRect frame = view.frame;
    self.isIndeterminateMode = NO;
    self.redCircle = [[BadgeView alloc] init];
    self.redCircle.userInteractionEnabled = NO;
    self.redCircle.isUserChangingBackgroundColor = YES;
    self.redCircle.backgroundColor = [UIColor redColor];
    self.countLabel = [[UILabel alloc] initWithFrame:self.redCircle.frame];
    self.countLabel.userInteractionEnabled = NO;
    self.count = count;
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.backgroundColor = [UIColor clearColor];
    [self setCircleAtFrame:CGRectMake((frame.size.width ? frame.size.width : 0) - notificHubDefaultDiameter * 2 / 3, -notificHubDefaultDiameter / 3, notificHubDefaultDiameter, notificHubDefaultDiameter)];
    [view addSubview:self.redCircle];
    [view addSubview:self.countLabel];
    [view bringSubviewToFront:self.redCircle];
    [view bringSubviewToFront:self.countLabel];
    self.hubView = view;
    [self checkZero];
}

#pragma mark - Public Method
- (void)setCircleAtFrame:(CGRect)frame {
    self.redCircle.frame = frame;
    self.initialCenter = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
    self.baseFrame = frame;
    self.initialFrame = frame;
    self.countLabel.frame = self.redCircle.frame;
    self.redCircle.layer.cornerRadius = frame.size.height / 2;
    self.countLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:frame.size.width / 2];
}

- (void)setCircleColor:(UIColor *)circleColor
            labelColor:(UIColor *)labelColor {
    self.redCircle.isUserChangingBackgroundColor = YES;
    self.redCircle.backgroundColor = circleColor;
    if (labelColor) {
        self.countLabel.textColor = labelColor;
    }
}

- (void)setCircleBorderColor:(UIColor *)color
                 borderWidth:(CGFloat)width {
    self.redCircle.layer.borderColor = color.CGColor;
    self.redCircle.layer.borderWidth = width;
}

- (void)moveCircleByX:(CGFloat)x
                    y:(CGFloat)y {
    CGRect frame = self.redCircle.frame;
    frame.origin.x += x;
    frame.origin.y += y;
    [self setCircleAtFrame:frame];
}
 
- (void)scaleCircleSizeByScale:(CGFloat)scale {
    CGRect fr = self.initialFrame;
    CGFloat width = fr.size.width * scale;
    CGFloat height = fr.size.height * scale;
    CGFloat wdiff = (fr.size.width - width) / 2;
    CGFloat hdiff = (fr.size.height - height) / 2;
    CGRect frame = CGRectMake(fr.origin.x + wdiff, fr.origin.y + hdiff, width, height);
    [self setCircleAtFrame:frame];
}

- (void)increment {
    [self incrementBy:1];
}

 
- (void)incrementBy:(NSInteger)amount {
    self.count += amount;
}

- (void)decrement {
    [self decrementBy:1];
}

- (void)decrementBy:(NSInteger)amount {
    if (amount >= self.count) {
        self.count = 0;
        return;
    }
    self.count -= amount;
}

- (void)hideCount {
    self.countLabel.hidden = YES;
    self.isIndeterminateMode = YES;
}

- (void)showCount {
    self.isIndeterminateMode = NO;
    [self checkZero];
}
 
- (void)pop {
    CGFloat height = self.baseFrame.size.height;
    CGFloat width = self.baseFrame.size.width;
    CGFloat popStartHeight = height * popStartRatio;
    CGFloat popStartWidth = width * popStartRatio;
    CGFloat timeStart = 0.05;
    CGFloat popOutHeight = height * popOutRatio;
    CGFloat popOutWidth = width * popOutRatio;
    CGFloat timeOut = 0.2;
    CGFloat popInHeight = height * popInRatio;
    CGFloat popInWidth = width * popInRatio;
    CGFloat timeIn = 0.05;
    CGFloat popEndHeight = height;
    CGFloat popEndWidth = width;
    CGFloat timeEnd = 0.05;
    
    CABasicAnimation *startSize = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    startSize.duration = timeStart;
    startSize.beginTime = 0;
    startSize.fromValue = [NSNumber numberWithFloat:popEndHeight / 2];
    startSize.toValue = [NSNumber numberWithFloat:popStartHeight / 2];
    startSize.removedOnCompletion = NO;
    
    CABasicAnimation *outSize = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    outSize.duration = timeOut;
    outSize.beginTime = timeStart;
    outSize.fromValue = startSize.toValue;
    outSize.toValue = [NSNumber numberWithFloat:popOutHeight / 2];
    outSize.removedOnCompletion = NO;
    
    CABasicAnimation *inSize = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    inSize.duration = timeIn;
    inSize.beginTime = timeStart + timeOut;
    inSize.fromValue = outSize.toValue;
    inSize.toValue = [NSNumber numberWithFloat:popInHeight / 2];
    inSize.removedOnCompletion = NO;
    
    CABasicAnimation *endSize = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    endSize.duration = timeEnd;
    endSize.beginTime = timeIn + timeOut + timeStart;
    endSize.fromValue = inSize.toValue;
    endSize.toValue = [NSNumber numberWithFloat:popEndHeight / 2];
    endSize.removedOnCompletion = NO;
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.duration = timeStart + timeOut + timeIn + timeEnd;
    group.animations = @[startSize, outSize, inSize, endSize];
    
    [self.redCircle.layer addAnimation:group forKey:nil];
    
    [UIView animateWithDuration:timeStart animations:^{
        CGRect frame = self.redCircle.frame;
        CGPoint center = self.redCircle.center;
        frame.size.height = popStartHeight;
        frame.size.width = popStartWidth;
        self.redCircle.frame = frame;
        self.redCircle.center = center;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:timeOut animations:^{
            CGRect frame = self.redCircle.frame;
            CGPoint center = self.redCircle.center;
            frame.size.height = popOutHeight;
            frame.size.width = popOutWidth;
            self.redCircle.frame = frame;
            self.redCircle.center = center;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:timeOut animations:^{
                CGRect frame = self.redCircle.frame;
                CGPoint center = self.redCircle.center;
                frame.size.height = popInHeight;
                frame.size.width = popInWidth;
                self.redCircle.frame = frame;
                self.redCircle.center = center;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:timeEnd animations:^{
                    CGRect frame = self.redCircle.frame;
                    CGPoint center = self.redCircle.center;
                    frame.size.height = popEndHeight;
                    frame.size.width = popEndWidth;
                    self.redCircle.frame = frame;
                    self.redCircle.center = center;
                }];
            }];
        }];
    }];
}
    

- (void)blink {
    [self setAlpha:blinkAlpha];
 
    [UIView animateWithDuration:blinkDuration animations:^{
        [self setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:blinkDuration animations:^{
            [self setAlpha:blinkAlpha];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:blinkDuration animations:^{
                [self setAlpha:1];
            }];
        }];
    }];
}

- (void)bump {
    if (!CGPointEqualToPoint(self.initialCenter, self.redCircle.center)) {
         // canel previous animation
    }
 
    [self bumpCenterY:0];
    
    [UIView animateWithDuration:bumpTimeSeconds animations:^{
        [self bumpCenterY:firstBumpDistance];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:bumpTimeSeconds animations:^{
            [self bumpCenterY:0];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:bumpTimeSeconds animations:^{
                [self bumpCenterY:bumpTimeSeconds2];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:blinkDuration animations:^{
                    [self bumpCenterY:0];
                }];
            }];
        }];
    }];
}

- (void)setCount:(NSInteger)count {
    _count = count;
    
    NSString *labelText = [@(count) stringValue];

    if (count > self.maxCount) {
        labelText = [@(self.maxCount) stringValue];
    }
    
    self.countLabel.text = labelText;
    [self checkZero];
}

- (void)setCountLabelFont:(UIFont *)font {
    self.countLabel.font = font;
}

- (UIFont *)countLabelFont {
    return self.countLabel.font;
}

- (void)bumpCenterY:(CGFloat)yVal {
    CGPoint center = self.redCircle.center;
    center.y = self.initialCenter.y - yVal;
    self.redCircle.center = center;
    self.countLabel.center = center;
}

- (void)setAlpha:(CGFloat)alpha {
    self.redCircle.alpha = alpha;
    self.countLabel.alpha = alpha;
}

- (void)setCountLabel:(UILabel *)countLabel {
    _countLabel = countLabel;
    countLabel.text = [@(self.count) stringValue];
    [self checkZero];
}

- (void)checkZero {
    if (self.count <= 0) {
        self.redCircle.hidden = YES;
        self.countLabel.hidden = YES;
    } else {
        self.redCircle.hidden = NO;
        if (!self.isIndeterminateMode) {
            self.countLabel.hidden = NO;
        }
    }
}

@end
