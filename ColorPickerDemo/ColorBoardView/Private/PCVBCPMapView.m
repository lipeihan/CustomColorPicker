//
//  PCVBCPMapView.m
//  DeepColorPickerViewDemo
//
//  Created by pierce on 16/3/2.
//  Copyright © 2016年 pierce. All rights reserved.
//

#import "PCVBCPMapView.h"

static const CGFloat kDefaultColor[][3] = {
    
    {255, 255, 255},
    {255, 241, 24},
    {255, 209, 24},
    {255, 162, 0},
    {255, 132, 0},
    {255, 102, 0},
    {255, 66, 0},
    {238, 39, 20},
    {216, 38, 20},
    {198, 28, 9},
    
    {101, 32, 230},
    {123, 63, 235},
    {162, 80, 255},
    {211, 93, 255},
    {245, 106, 223},
    {255, 133, 220},
    {255, 100, 165},
    {248, 30, 122},
    {238, 6, 109},
    {198, 19, 98},
    
    {0, 0, 0},
    {72, 72, 72},
    {191, 243, 91},
    {138, 230, 76},
    {60, 213, 89},
    {32, 184, 114},
    {0, 198, 255},
    {0, 162, 255},
    {0, 144, 255},
    {14, 50, 229},
};

@interface PCVBCPMapView () {
    
    NSInteger _currentSelectedCellIndex;
}

@property (strong, nonatomic) UIImage       *colorMapImage;
@property (strong, nonatomic) UIImageView   *colorPickerCrossIndicator;

/**
 *  UIColor, default is DEFAULT_COLORS
 */
@property (strong, nonatomic) NSArray<UIColor*>             *colors;
@property (nonatomic, strong) UIImageView                   *cellIndicator;
@property (nonatomic, strong) NSMutableArray<NSValue *>     *cellFrameInfos;

@end

@implementation PCVBCPMapView

#pragma mark - initial

- (instancetype)init {
    if (self = [super init]) {
        [self initial];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initial];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)initial {
    
    self.gridCellLayoutInfo = CGSizeMake(10, 3);
    
    self.colors = [self generateDefaultColors];
    
    self.cellFrameInfos = [NSMutableArray arrayWithCapacity:self.gridCellLayoutInfo.width * self.gridCellLayoutInfo.height];
    
    self.clipsToBounds = YES;
    
    self.colorMapImage = [UIImage imageNamed:@"PCVBCPResource.bundle/drcolorpicker-colormap"];
    
    [self initColorPickerIndicator];
}

- (void)initColorPickerIndicator {
    
    UIImage *indicatorImage = [UIImage imageNamed:@"PCVBCPResource.bundle/img_cross"];
    self.colorPickerCrossIndicator = [[UIImageView alloc] initWithImage:indicatorImage];
    self.colorPickerCrossIndicator.userInteractionEnabled = NO;
    [self addSubview:self.colorPickerCrossIndicator];
    
    self.cellIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.cellIndicator.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cellIndicator.layer.borderWidth = 2;
    [self addSubview:self.cellIndicator];
    
    self.colorPickerCrossIndicator.hidden = _usingGridCell;
    self.cellIndicator.hidden = !_usingGridCell;
}

#pragma mark - Life Cycle

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self resetColorMapView];
    
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    if (self.usingGridCell) {
        
        [self drawColorCells:UIGraphicsGetCurrentContext() frame:rect];
        
    }else{
        
        [self.colorMapImage drawInRect:rect];
    }
}

- (void)resetColorMapView {
    
    CGFloat centerX = 0;
    CGFloat centerY = self.bounds.size.height;
    self.colorPickerCrossIndicator.center = CGPointMake(centerX, centerY);
}

#pragma mark - Touch event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self changeColorWhenTouchChange:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self changeColorWhenTouchChange:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self changeColorWhenTouchChange:event];
    [self touchDidEnd];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self changeColorWhenTouchChange:event];
    [self touchDidEnd];
}

- (void)touchDidEnd {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorMapViewDidEndTouch:)]) {
        [self.delegate colorMapViewDidEndTouch:self];
    }
}

/**
 *  根据当前被触碰的位置得到当前的颜色
 *
 *  @param event 当前的touch事件
 */
- (void)changeColorWhenTouchChange:(UIEvent *)event {
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint location = [touch locationInView:self];
    
    if (self.usingGridCell) {
        
        return [self changeColorWhenTouchChangeWithColorCell:location];
        
    }else{
        
        return [self changeColorWhenTouchChangeWithImage:location];
    }
    
}

- (void)changeColorWhenTouchChangeWithImage:(CGPoint)location {
    
    CGFloat x = location.x;
    if (x < 0) {
        x = 0;
    } else if (x > self.bounds.size.width) {
        x = self.bounds.size.width;
    }
    
    CGFloat y = location.y;
    if (y < 0) {
        y = 0;
    } else if (y > self.bounds.size.height) {
        y = self.bounds.size.height - 1;
    }
    location = CGPointMake(x, y);
    
    
    UIColor *color = [self pixelColorAtLocation:location];
    self.colorPickerCrossIndicator.center = location;
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorMapView:hasPickedColor:)]) {
        [self.delegate colorMapView:self hasPickedColor:color];
    }
}

- (void)changeColorWhenTouchChangeWithColorCell:(CGPoint)location {
    
    if (!self.usingGridCell) {
        
        return;
    }
    
    CGFloat x = location.x;
    if (x < 0) {
        x = 1;
    } else if (x > self.bounds.size.width) {
        x = self.bounds.size.width - 1;
    }
    
    CGFloat y = location.y;
    if (y < 0) {
        y = 1;
    } else if (y > self.bounds.size.height) {
        y = self.bounds.size.height - 1;
    }
    location = CGPointMake(x, y);
    
    CGPoint point = CGPointMake(x, y);
    
    [self setCurrentSelectedCellIndex:[self cellIndexAtPoint:point]];
}


#pragma mark - Image Color

/**
 *  取得某一点位置上的颜色值
 *
 *  注意：提供的点必须是和图片上面的点可以相对应的，否则取出的颜色是错误的
 *  @return 取得的颜色
 */
- (UIColor *)pixelColorAtLocation:(CGPoint)point {
    
    UIColor* color = nil;
    CGImageRef inImage = self.colorMapImage.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) {
        return nil; /* error */
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    
    CGFloat wRate = w / self.bounds.size.width;
    CGFloat hRate = h / self.bounds.size.height;
    
    //在CGContext中画入图片
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y * hRate))+round(point.x * wRate));
        if (offset >= w * 4 * h) {
            color = [UIColor colorWithRed:(0/255.0f) green:(0/255.0f) blue:(0/255.0f) alpha:(1/255.0f)];
        } else {
            int alpha =  data[offset];
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        }
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    return color;
}

/**
 *  通过图片获得和图片大小一样的画布
 *
 *  @param inImage
 *
 *  @return 返回画布对象
 */
- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    size_t             bitmapByteCount;
    size_t             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

#pragma mark - Color Cell

- (UIColor *)girdColorAtIndex:(NSInteger)index {
    
    UIColor *color;
    
    if (index < 0 || index >= self.colors.count) {
        return [UIColor whiteColor];
    }

    color = self.colors[index];
    
    return color;
}

- (UIColor *)girdColorAtLocation:(CGPoint)point {
    
    NSInteger index = [self cellIndexAtPoint:point];
    return [self girdColorAtIndex:index];
}

- (void)drawColorCells:(CGContextRef)context
                 frame:(CGRect)rect {
    
    //Draw the color cells
    if (self.colors.count == 0) {
        return;
    }
    
    NSInteger columnCount = (int)self.gridCellLayoutInfo.width;
    NSInteger rowCount = (int)self.gridCellLayoutInfo.height;
    
    CGFloat w = rect.size.width / columnCount;
    CGFloat h = rect.size.height/ rowCount;
    
    // draw color blocks
    
    for (int i  = 0; i < rowCount ; i++) {
        for (int j = 0; j < columnCount; j++ ) {
            
            UIColor *color;
            NSInteger index = i * columnCount + j;
            
            if (index >= self.colors.count) {
                color = [UIColor whiteColor];
            }else{
                color = self.colors[index];
            }
            
            CGRect drawRect = CGRectMake(j * w, h * i, w, h);
            
            /**
             *  @author Pierce, 16-06-30 10:06:57
             *
             *  为了解决初始的时候,CellIndicator位置不对的问题
             *
             */
            if (self.currentSelectedCellIndex == index) {
                self.cellIndicator.frame = drawRect;
            }
            
            NSValue *frameValue = [NSValue valueWithCGRect:drawRect];
            
            if (index >= self.cellFrameInfos.count) {
               
                [self.cellFrameInfos addObject:frameValue];
            }else{
                self.cellFrameInfos[index] = frameValue;
            }
            
            CGContextSetFillColorWithColor(context, color.CGColor);
            CGContextFillRect(context, drawRect);

        }
    }
}


#pragma mark Utils

- (NSInteger)cellIndexAtPoint:(CGPoint)point {
    
    CGRect rect = self.bounds;
    
    NSInteger columnCount = (int)self.gridCellLayoutInfo.width;
    NSInteger rowCount = (int)self.gridCellLayoutInfo.height;
    
    CGFloat w = rect.size.width / columnCount;
    CGFloat h = rect.size.height/ rowCount;
    
    NSInteger row = floor(point.y / h);
    NSInteger column = floor(point.x / w);
    
    NSInteger index = row * columnCount + column;
    
    
    if (index < 0) {
        index = 0;
    }
    
    return index;
}

- (CGRect)frameAtIndex:(NSInteger)index{
    
    if (index >= self.cellFrameInfos.count || index < 0) {
        return CGRectZero;
    }
    
    NSValue *frameValue = self.cellFrameInfos[index];
    return [frameValue CGRectValue];
}

- (NSArray *)generateDefaultColors
{
    NSMutableArray *colors = [NSMutableArray array];
    for (int i=0; i< sizeof(kDefaultColor) / (sizeof(CGFloat) * 3); i++) {
        UIColor *color = [UIColor colorWithRed:kDefaultColor[i][0]/255.0f green:kDefaultColor[i][1]/255.0f blue:kDefaultColor[i][2]/255.0f alpha:1];
        [colors addObject:color];
    }
    NSLog(@"color count %ld", (unsigned long)colors.count);
    return colors;
}

#pragma mark - Setter 

- (void)setUsingGridCell:(BOOL)usingGridCell {
    
    _usingGridCell = usingGridCell;
    
    self.colorPickerCrossIndicator.hidden = usingGridCell;
    self.cellIndicator.hidden = !usingGridCell;
}

- (void)setCellSelectdBoraderColor:(UIColor *)cellSelectdBoraderColor {
    
    _cellSelectdBoraderColor = cellSelectdBoraderColor;
    self.cellIndicator.layer.borderColor = _cellSelectdBoraderColor.CGColor;
}

- (UIColor *)setCurrentSelectedCellIndex:(NSInteger)currentSelectedCellIndex {
    
    if ((currentSelectedCellIndex < -1)){
        return [UIColor whiteColor];
    }
    
    if (currentSelectedCellIndex >= (int)self.colors.count) {
        return  [UIColor whiteColor];
    }
    
    _currentSelectedCellIndex = currentSelectedCellIndex;
    
    if (!self.usingGridCell) {
        return nil;
    }
    
    UIColor *color = [self girdColorAtIndex:_currentSelectedCellIndex];
    self.cellIndicator.frame = [self frameAtIndex:_currentSelectedCellIndex];

    if (self.delegate && [self.delegate respondsToSelector:@selector(colorMapView:hasPickedColor:)]) {
        [self.delegate colorMapView:self hasPickedColor:color];
    }
    
    return color;
}

- (NSInteger)currentSelectedCellIndex {
    
    return  _currentSelectedCellIndex;
}

- (NSInteger)colorCellsNum {
    
    return self.colors.count;
}

@end
