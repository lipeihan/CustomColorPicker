//
//  ColorPickerView.m
//  DeepColorPickerViewDemo
//
//  Created by pierce on 16/3/2.
//  Copyright © 2016年 pierce. All rights reserved.
//

#import "ColorBoardView.h"
#import "PCVBCPMapView.h"
#import "PCVBCPDepthView.h"

#import "PCVBCPIndicator.h"

#define kColorIndicatorCenterY (isiPad ? -25 : -18)

@interface ColorBoardView ()<PCVBCPMapViewDelegate,PCVBCPDepthViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) NSMutableArray *customConstraints;

@property (weak, nonatomic) IBOutlet PCVBCPMapView *colorMapView;
@property (weak, nonatomic) IBOutlet PCVBCPDepthView *colorDepthView;

@property (strong, nonatomic) PCVBCPIndicator *colorIndicator;
@property (strong, nonatomic) UIColor *color;

//Layout
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewLTSC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upperDepthViewLHC;

@end

@implementation ColorBoardView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)updateConstraints
{
    [self removeConstraints:self.customConstraints];
    [self.customConstraints removeAllObjects];
    
    if (self.containerView != nil) {
        UIView *view = self.containerView;
        NSDictionary *views = NSDictionaryOfVariableBindings(view);
        
        [self.customConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:
          @"H:|[view]|" options:0 metrics:nil views:views]];
        [self.customConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:
          @"V:|[view]|" options:0 metrics:nil views:views]];
        
        [self addConstraints:self.customConstraints];
    }
    
    [super updateConstraints];
}

- (void)commonInit
{
    self.customConstraints = [[NSMutableArray alloc] init];
    
    UIView *view = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                     owner:self
                                                   options:nil];
    for (id object in objects) {
        if ([object isKindOfClass:[UIView class]]) {
            view = object;
            break;
        }
    }
    
    if (view != nil) {
        self.containerView = view;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        [self setNeedsUpdateConstraints];
    }
    
    [self customInit];
}

#pragma mark - Life Cycle

- (void)customInit {
    
    _showDepth = YES;
    _upperDepthViewHeight = 30;
    _upperDepthViewHeightiPad = 30;
    
    [self initViews];
}


- (void)initViews {
    
     self.clipsToBounds = NO;

    self.colorMapView.delegate = self;
    self.colorDepthView.delelgate = self;
    
    self.colorMapView.exclusiveTouch = YES;
    self.colorDepthView.exclusiveTouch = YES;
    
    [self initIndicator];
    
    self.cellSelectdBoraderColor = [UIColor whiteColor];
    
    self.color = [UIColor whiteColor];
}

- (void)initIndicator {
    
    CGFloat width = isiPad ? 38 : 28;
    CGFloat height = isiPad ? 46 : 34;
    CGRect indicatorFrame = CGRectMake(0, 0, width, height);
    
    self.colorIndicator = [[PCVBCPIndicator alloc] initWithFrame:indicatorFrame];
    [self addSubview:self.colorIndicator];
    self.colorIndicator.hidden = YES;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    CGFloat height = isiPad ? self.upperDepthViewHeightiPad : self.upperDepthViewHeight;
    self.upperDepthViewLHC.constant = height;
    
    if (!self.showDepth) {
        self.colorDepthView.hidden = YES;
        self.mapViewLTSC.constant = 0;
    }else{
       self.mapViewLTSC.constant = height;
    }
}

#pragma mark - delegates

#pragma mark PCVBCPDepthViewDelegate

- (void)colorDepthViewDidEndTouch:(PCVBCPDepthView *)depthView {
    [self didEndTouchColorPickerView];
}

- (void)colorDepthView:(PCVBCPDepthView *)depthView hasPickedColor:(UIColor *)color {
    
    [self colorViewHasPickedColor:color];
}

#pragma mark PCVBCPMapViewDelegate

- (void)colorMapView:(PCVBCPMapView *)colorMapView hasPickedColor:(UIColor *)color {
    [self colorViewHasPickedColor:color];
}

- (void)colorMapViewDidEndTouch:(PCVBCPMapView *)colorMapView {
    [self didEndTouchColorPickerView];
}

#pragma mark Delegate Utils

- (void)didEndTouchColorPickerView {
    
    self.colorIndicator.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorBoardView:HasPickedColor:)]) {
        [self.delegate colorBoardView:self HasPickedColor:self.color];
    }
}

- (void)colorViewHasPickedColor:(UIColor *)color {
    
    UIColor *depthColor = [self.colorDepthView setCurrentColorToGetDepthColor:color];
    self.color = depthColor;
    
    if (self.showIndicatorWhenTouchLowwerView) {
        [self showColorIndicatorWithColor:depthColor];
    }
}


#pragma mark - Utils

- (void)showColorIndicatorWithColor:(UIColor *)color {
    CGFloat centerX = [self.colorDepthView colorIndicatorLocation];
    self.colorIndicator.center = CGPointMake(centerX, kColorIndicatorCenterY);
    self.colorIndicator.colorView.backgroundColor = color;
    self.colorIndicator.hidden = NO;
}


- (UIColor *)currentColor {
    return self.color;
}

#pragma mark - Setter 

- (BOOL)usingGridCell {
    
    return self.colorMapView.usingGridCell;
}

- (void)setUsingGridCell:(BOOL)usingGridCell {
    
    self.colorMapView.usingGridCell = usingGridCell;
}

- (void)setCellSelectdBoraderColor:(UIColor *)cellSelectdBoraderColor {
    
    self.colorMapView.cellSelectdBoraderColor = cellSelectdBoraderColor;
}

- (UIColor *)cellSelectdBoraderColor {
    
    return self.colorMapView.cellSelectdBoraderColor;
}

- (void)setCircleIndicatorLength:(CGFloat)circleIndicatorLength {
    
     self.colorDepthView.circleIndicatorLength = circleIndicatorLength;
}

- (CGFloat)circleIndicatorLength {
    
    return self.colorDepthView.circleIndicatorLength;
}

- (void)setCircleBoarderWidth:(CGFloat)circleBoarderWidth {
    
    self.colorDepthView.circleBoarderWidth = circleBoarderWidth;
}

- (CGFloat)circleBoarderWidth {
    
    return self.colorDepthView.circleBoarderWidth;
}

- (NSInteger)colorCellsNum {
    
    return self.colorMapView.colorCellsNum;
}

- (NSInteger)currentSelectedCellIndex {
    
    return self.colorMapView.currentSelectedCellIndex;
}

- (UIColor *)setCurrentSelectedCellIndex:(NSInteger)currentSelectedCellIndex {
    
    return [self.colorMapView setCurrentSelectedCellIndex:currentSelectedCellIndex];
}

@end
