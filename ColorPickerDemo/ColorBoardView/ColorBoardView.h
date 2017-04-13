//
//  ColorPickerView.h
//  DeepColorPickerViewDemo
//
//  Created by pierce on 16/3/2.
//  Copyright © 2016年 pierce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorBoardViewDelegate;

@interface ColorBoardView : UIView

#pragma mark - 布局信息

/**
 *  是否显示深度选则的view，即DepthView
 */
@property (nonatomic, assign) IBInspectable BOOL showDepth;

/**
 *  上面DepthView的圆圈提示的大小
 */
@property (nonatomic, assign) IBInspectable CGFloat circleBoarderWidth;
/**
 *  上面DepthView的圆圈的Boarder宽度
 */
@property (nonatomic, assign) IBInspectable CGFloat circleIndicatorLength;
/**
 *  在用户点击了下面的选取颜色的时候，是否展示 伸展出的方形提示框
 */
@property (nonatomic, assign) IBInspectable BOOL showIndicatorWhenTouchLowwerView;
/**
 *  上面DepthView的高度
 */
@property (nonatomic, assign) IBInspectable CGFloat upperDepthViewHeight;
/**
 *  上面DepthView的高度 iPad
 */
@property (nonatomic, assign) IBInspectable CGFloat upperDepthViewHeightiPad;


/**
 *  @author Pierce, 16-06-30 08:06:36
 *
 *  是否用网格Cell的形式展示颜色
 *
 */
@property (nonatomic, assign) IBInspectable BOOL    usingGridCell;
@property (nonatomic, strong) IBInspectable UIColor *cellSelectdBoraderColor;

#pragma mark - 状态控制

- (NSInteger)currentSelectedCellIndex;
/**
 *  设置选中位置
 *
 *  @param currentSelectedCellIndex 选中的index，范围为 [-1 ~ colorCellsNum)
 *
 *  @return 返回对应index的数据
 *
 */
- (UIColor *)setCurrentSelectedCellIndex:(NSInteger)currentSelectedCellIndex;

@property (nonatomic, assign, readonly) NSInteger   colorCellsNum;

@property (strong, nonatomic, readonly) UIColor *currentColor;
@property (weak, nonatomic) IBOutlet id<ColorBoardViewDelegate> delegate;

@end

#pragma mark - 协议

@protocol ColorBoardViewDelegate <NSObject>

- (void)colorBoardView:(ColorBoardView *)colorBoardView HasPickedColor:(UIColor *)color;

@end
