//
//  ColorDeepView.m
//  DeepColorPickerViewDemo
//
//  Created by pierce on 16/3/2.
//  Copyright © 2016年 pierce. All rights reserved.
//

#import "PCVBCPDepthView.h"

@interface PCVBCPDepthView ()

@property (strong ,nonatomic) UIImage *colorSetImage;
@property (strong ,nonatomic) UIView *colorPickerIndicator;

@property (assign, nonatomic) CGFloat currentDepthOffset;
@property (strong, nonatomic) UIColor *currentColor;

@end

@implementation PCVBCPDepthView

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
    
    _circleBoarderWidth = 30;
    
    [self resetColorDepthView];
    self.colorPickerIndicator = [[UIView alloc] init];
    self.colorPickerIndicator.userInteractionEnabled = NO;
    [self addSubview:self.colorPickerIndicator];
    
    [self initIndicator];
}

- (void)initIndicator {
    
    self.colorPickerIndicator.layer.borderColor = [UIColor whiteColor].CGColor;
    self.colorPickerIndicator.layer.borderWidth = 2;
    self.colorPickerIndicator.layer.shadowColor = [UIColor grayColor].CGColor;
    self.colorPickerIndicator.layer.shadowOffset = CGSizeZero;
    self.colorPickerIndicator.layer.shadowOpacity = 0.5;
}

#pragma mark - Life Cycle

- (void)layoutSubviews {
    [super layoutSubviews];
    
    /**
     *  在layoutSubviews 中画出颜色图片，使得无论frame如何改变，颜色底图都是最适应view大小的
     */
    [self reloadColorIndicatorView];
    [self drawAllColorsWithSize:self.bounds.size];
}

- (void)reloadColorIndicatorView {
    
    CGFloat centerX = self.bounds.size.width * self.currentDepthOffset;
    CGFloat centerY = self.frame.size.height / 2;
    CGFloat size = self.circleIndicatorLength;
   
    self.colorPickerIndicator.frame = CGRectMake(0, 0, size, size);
    self.colorPickerIndicator.center = CGPointMake(centerX, centerY);
    self.colorPickerIndicator.layer.cornerRadius = size / 2;
    self.colorPickerIndicator.backgroundColor = [self pixelColorAtCurrentPoint];
}

- (void)resetColorDepthView {
    
    self.currentColor = [UIColor whiteColor];
    self.currentDepthOffset = 0.5;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.colorSetImage drawInRect:rect];
}

#pragma mark - Touch Event

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
    if (self.delelgate && [self.delelgate respondsToSelector:@selector(colorDepthViewDidEndTouch:)]) {
        [self.delelgate colorDepthViewDidEndTouch:self];
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
    
    CGFloat x = location.x;
    if (x <= 0) {
        x = 1;
    } else if (x > self.bounds.size.width - 1) {
        x = self.bounds.size.width - 1;
    }

    self.currentDepthOffset = x / self.bounds.size.width;
    
    self.colorPickerIndicator.center = CGPointMake(self.bounds.size.width * self.currentDepthOffset, self.frame.size.height / 2);
    UIColor *color = [self pixelColorAtCurrentPoint];
    self.colorPickerIndicator.backgroundColor = color;
    if (self.delelgate && [self.delelgate respondsToSelector:@selector(colorDepthView:hasPickedColor:)]) {
        [self.delelgate colorDepthView:self hasPickedColor:color];
    }
}


#pragma mark - Utils

- (CGFloat)colorIndicatorLocation {
    
    return self.currentDepthOffset * self.bounds.size.width;
}


/**
 *  通过提供的size生成一张包含所有颜色的底图
 *
 *  @param size 图片尺寸
 */
- (void)drawAllColorsWithSize:(CGSize)size {
    
    /**
     *  主要用来创建一个基于位图的图形上下文（这里称之为画布）
     *
     *  @param size   在调用UIGraphicsGetImageFromCurrentImageContext 时返回的画布的尺寸，这个尺寸是以像素点的方式返回，所以实际宽高的输出是size的值乘上后面提供的scale参数
     *  @param opaque 布尔值，表示图像是否不透明
     *  @param scale  生成bitmap的比例因子，如果设置的值为0的话表示和屏幕的scale一样
     */
    UIGraphicsBeginImageContextWithOptions(size, 0, 0);
    //获得当前画布
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 创建色彩空间对象
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    // 创建所有颜色范围，所有颜色讲在这些颜色区间实现渐变
    CGColorRef beginColor = [UIColor whiteColor].CGColor;
    CGColorRef color = self.currentColor.CGColor;
    CGColorRef endColor = [UIColor blackColor].CGColor;
    // 创建颜色数组
    CFArrayRef colorArray = CFArrayCreate(kCFAllocatorDefault, (const void*[]){beginColor,color, endColor}, 3, nil);
    // 创建渐变对象
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorSpaceRef, colorArray, (CGFloat[]){
        0.0f, // 对应起点颜色位置
        0.5f,
        1.0f // 对应终点颜色位置
    });
    
    // 释放颜色数组
    CFRelease(colorArray);
    // 释放色彩空间
    CGColorSpaceRelease(colorSpaceRef);
    //圈位置
    CGContextSaveGState(context);
    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
    //填充渐变色
    CGContextDrawLinearGradient(context, gradientRef,CGPointMake
                                (0, 0) ,CGPointMake(size.width,0),
                                0);
    CGGradientRelease(gradientRef); //释放渐变对象
    
    self.colorSetImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);// 恢复到之前的context
    UIGraphicsEndImageContext();
}

- (UIColor *)setCurrentColorToGetDepthColor:(UIColor *)color {
    self.currentColor = color;
    [self drawAllColorsWithSize:self.bounds.size];
    [self setNeedsDisplay];
    UIColor *depthColor = [self pixelColorAtCurrentPoint];
    self.colorPickerIndicator.backgroundColor = depthColor;
    return depthColor;
}


#pragma mark getColor

/**
 *  取得某一点位置上的颜色值
 *
 *  注意：提供的点必须是和图片上面的点可以相对应的，否则取出的颜色是错误的
 *
 *  @return 取得的颜色
 */
- (UIColor *)pixelColorAtCurrentPoint {
    CGPoint point = CGPointMake(self.bounds.size.width * self.currentDepthOffset, self.bounds.size.height / 2);
    UIColor* color = nil;
    CGImageRef inImage = self.colorSetImage.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) {
        return nil; /* error */
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    //在CGContext中画入图片
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y * [UIScreen mainScreen].scale))+round(point.x * [UIScreen mainScreen].scale));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        //NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    return color;
}

/**
 *  通过图片获得和图片大小一样的画布
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

#pragma mark - Setter 

- (void)setCircleIndicatorLength:(CGFloat)circleIndicatorLength {
    
    _circleIndicatorLength = circleIndicatorLength;
    
    [self reloadColorIndicatorView];
}

- (void)setCircleBoarderWidth:(CGFloat)circleBoarderWidth {
    
    _circleBoarderWidth = circleBoarderWidth;
    
    self.colorPickerIndicator.layer.borderWidth = circleBoarderWidth;
}

@end
