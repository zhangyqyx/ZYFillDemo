//
//  ColorPickerView.m
//  ZYFillDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2018/1/29.
//  Copyright © 2018年 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

#import "ColorPickerView.h"

@implementation ColorPickerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatImageView];
    }
    return self;
}
- (void)creatImageView {
    self.imgView = [[UIImageView alloc] init];
    self.imgView.image = [UIImage imageNamed:@"pickerColor.png"];
    [self addSubview:self.imgView];
}
- (void)layoutSubviews {
    self.imgView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - 点击结束
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    // tap点击的位置
    CGPoint point = [touch locationInView:self.imgView];
    // 1.调用自定义方法,从【点】中取颜色
    UIColor *selectedColor = [self colorAtPixel:point];

//    UIColor *selectedColor = [self getPixelColorAtLocation:point];
    // 2.告诉代理,解析出来的颜色
    if ([self.pickedColorDelegate respondsToSelector:@selector(pickedColor:)]) {
        [self.pickedColorDelegate pickedColor:selectedColor];
    }
}
- (UIColor *)colorAtPixel:(CGPoint)point {
    // 判断是否点击在这个点上
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.imgView.frame.size.width, self.imgView.frame.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.imgView.image.CGImage;
    NSUInteger width = self.imgView.frame.size.width;
    NSUInteger height = self.imgView.frame.size.height;
    //创建色彩空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    //颜色转换
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    //绘图
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // 获取颜色值
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end
