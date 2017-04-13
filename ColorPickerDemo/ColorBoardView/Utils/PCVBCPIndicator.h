//
//  PCVBCPIndicator.h
//  ColorPickerDemo
//
//  PCVBCP ->  PCV Boader Color Picker
//
//  Created by Pierce on 16/6/30.
//  Copyright © 2016年 Pierce. All rights reserved.
//

#import <UIKit/UIKit.h>

#define isiPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface PCVBCPIndicator : UIView

@property (strong, nonatomic) UIImageView   *frameImageView;
@property (strong, nonatomic) UIView        *colorView;

@end
