//
//  PCVBCPIndicator.m
//  ColorPickerDemo
//
//  Created by Pierce on 16/6/30.
//  Copyright © 2016年 Pierce. All rights reserved.
//

#import "PCVBCPIndicator.h"

@implementation PCVBCPIndicator

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.frameImageView = [[UIImageView alloc] initWithFrame:frame];
        self.frameImageView.image = [UIImage imageNamed:@"PCVBCPResource.bundle/img_square.png"];
        self.frameImageView.contentMode = UIViewContentModeCenter;
        
        CGFloat width = frame.size.width - 6;
        CGFloat height = frame.size.height - (isiPad ? 13 : 11);
        self.colorView = [[UIView alloc] initWithFrame:CGRectMake(3, 2, width, height)];
        
        [self addSubview:self.colorView];
        [self addSubview:self.frameImageView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
