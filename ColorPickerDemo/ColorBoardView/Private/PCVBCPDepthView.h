//
//  ColorDeepView.h
//  DeepColorPickerViewDemo
//
//  PCVBCP ->  PCV Boader Color Picker
//
//  Created by pierce on 16/3/2.
//  Copyright © 2016年 pierce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCVBCPDepthViewDelegate;

@interface PCVBCPDepthView : UIView

@property (nonatomic, assign) CGFloat circleIndicatorLength;
@property (nonatomic, assign) CGFloat circleBoarderWidth;

@property (weak, nonatomic) id<PCVBCPDepthViewDelegate> delelgate;
@property (assign, nonatomic, readonly) CGFloat colorIndicatorLocation;

- (void)resetColorDepthView;
- (UIColor *)setCurrentColorToGetDepthColor:(UIColor *)color;

@end

@protocol PCVBCPDepthViewDelegate <NSObject>

- (void)colorDepthView:(PCVBCPDepthView *)depthView hasPickedColor:(UIColor *)color;
- (void)colorDepthViewDidEndTouch:(PCVBCPDepthView *)depthView;

@end
