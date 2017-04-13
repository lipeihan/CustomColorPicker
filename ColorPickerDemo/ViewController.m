//
//  ViewController.m
//  ColorPickerDemo
//
//  Created by Pierce on 16/6/30.
//  Copyright © 2016年 Pierce. All rights reserved.
//

#import "ViewController.h"
#import "ColorBoardView.h"

@interface ViewController () <ColorBoardViewDelegate>

@property (weak, nonatomic) IBOutlet ColorBoardView *colorPicker;
@property (strong, nonatomic) IBOutlet UIView *showColorView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.colorPicker.delegate = self;
    
    //设置默认选中颜色
//    [self.colorPicker setCurrentSelectedCellIndex:9];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.colorPicker setCurrentSelectedCellIndex:-1];
//    });
}

#pragma mark - ColorBoardViewDelegate

- (void)colorBoardView:(ColorBoardView *)colorBoardView HasPickedColor:(UIColor *)color {
    
    [self.showColorView setBackgroundColor:color];
}

@end
