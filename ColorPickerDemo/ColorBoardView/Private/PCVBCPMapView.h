//
//  PCVBCPMapView.h
//  DeepColorPickerViewDemo
//
//  PCVBCP ->  PCV Boader Color Picker
//
//  Created by pierce on 16/3/2.
//  Copyright © 2016年 pierce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCVBCPMapViewDelegate;

@interface PCVBCPMapView : UIView

@property (nonatomic, assign) BOOL          usingGridCell;
@property (nonatomic, strong) UIColor       *cellSelectdBoraderColor;

@property (nonatomic, assign) CGSize gridCellLayoutInfo;

@property (weak, nonatomic) id<PCVBCPMapViewDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger   colorCellsNum;

- (void)resetColorMapView;

//Selected
- (NSInteger)currentSelectedCellIndex;
- (UIColor *)setCurrentSelectedCellIndex:(NSInteger)currentSelectedCellIndex;

@end


@protocol PCVBCPMapViewDelegate <NSObject>

- (void)colorMapView:(PCVBCPMapView *)colorMapView hasPickedColor:(UIColor *)color;
- (void)colorMapViewDidEndTouch:(PCVBCPMapView *)colorMapView;

@end
