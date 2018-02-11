





//
//  MyimageView.m
//  TextHuaTu
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2018/1/29.
//  Copyright © 2018年 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

#import "MyimageView.h"
#import "LinkedListStack.h"
@interface MyimageView()
@property (nonatomic,assign) CGImageRef cgimage;
@property (nonatomic,assign) CGFloat currentScale;

/** 上一次点击的点 */
@property(nonatomic , assign)CGPoint lastPoint;


@end
@implementation MyimageView
-(instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
    }
    return self;
}
/**
 撤销操作
 */
- (void)revokeOption {
    
    CGPoint lastPoint = [self.revokePoints.lastObject CGPointValue];
    [self floodFillFromPoint:lastPoint withColor:[UIColor whiteColor]];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint tpoint = [[[event allTouches] anyObject] locationInView:self];
    NSArray * touchesArr=[[event allTouches] allObjects];
    if (touchesArr.count == 1) {
        [self floodFillFromPoint:tpoint withColor:self.newcolor];
    }
}
// 计算俩点之间的距离
-(double)distance:(CGPoint)p1 point:(CGPoint)p2{
    double distance=sqrt(pow(p1.x-p2.x,2)+pow(p1.y-p2.y,2));
    return distance;
}
- (void ) floodFillFromPoint:(CGPoint)startPoint withColor:(UIColor *)newColor{
    CGPoint tapPoint = startPoint;
    // 颜色差异度
    int tolerance = 10;
    BOOL  antiAlias = NO;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = [self.image CGImage];
    NSUInteger width = CGImageGetWidth(self.image.CGImage);
    NSUInteger height = CGImageGetHeight(self.image.CGImage);
    // 装换坐标 实际坐标转换成像素坐标
    size_t www =   startPoint.x * _scaleNum;
    size_t hhh =   startPoint.y *_scaleNum;
    
    startPoint = CGPointMake(www, hhh);
    unsigned char* imageData = malloc(width * height * 4) ;
    memset(imageData, 0, width * height * 4);
    
    NSLog(@"--------------%p",imageData);
    NSUInteger bytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(imageRef);
    NSUInteger bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    NSLog(@"imageRef = %@" , imageRef);
    if (kCGImageAlphaLast == (uint32_t)bitmapInfo || kCGImageAlphaFirst == (uint32_t)bitmapInfo) {
        bitmapInfo = (uint32_t)kCGImageAlphaPremultipliedLast;
    }
     //开启图片上下文
    CGContextRef context = CGBitmapContextCreate(imageData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
   // 获取点击 像素点的颜色
    unsigned int byteIndex = (bytesPerRow * roundf(startPoint.y)) + roundf(startPoint.x) * bytesPerPixel;
    unsigned int ocolor = getColorCode(byteIndex, imageData);
    if (ocolor == 50529279 || ocolor == 67372287) {
        return;
    }
    
    // 判断 点击的是否是边框
    unsigned int blackcolor = getColorCodeFromUIColor([UIColor blackColor],bitmapInfo&kCGBitmapByteOrderMask);
    if (compareColor(blackcolor, ocolor, 0)) {
        return;
    }
    // 如果新的颜色和旧的颜色 相同直接返回
    if (compareColor(ocolor, getColorCodeFromUIColor(newColor,bitmapInfo&kCGBitmapByteOrderMask), 10)) {
        return;
    }
    // 新的颜色  把新的颜色转换成容易储存的形式
    int newRed, newGreen, newBlue, newAlpha;
    const CGFloat *components = CGColorGetComponents(newColor.CGColor);
    if(CGColorGetNumberOfComponents(newColor.CGColor) == 2){
        newRed   = newGreen = newBlue = components[0] * 255;
        newAlpha = components[1] * 255;
    }else if (CGColorGetNumberOfComponents(newColor.CGColor) == 4){
        if ((bitmapInfo&kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Little){
            newRed   = components[2] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[0] * 255;
            newAlpha = 255;
        }else{
            newRed   = components[0] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[2] * 255;
            newAlpha = 255;
        }
    }
    
    unsigned int ncolor = (newRed << 24) | (newGreen << 16) | (newBlue << 8) | newAlpha;
    
    LinkedListStack *points = [[LinkedListStack alloc] initWithCapacity:500 incrementSize:500 andMultiplier:(int)height];
    LinkedListStack *antiAliasingPoints = [[LinkedListStack alloc] initWithCapacity:500 incrementSize:500 andMultiplier:(int)height ];
    
    // roundf 四舍五入 取整数
    int x = roundf(startPoint.x);
    int y = roundf(startPoint.y);
    
    [points pushFrontX:x andY:y];
    
    
    unsigned int color;

    BOOL spanLeft,spanRight;
    
    while ([points popFront:&x andY:&y] != INVALID_NODE_CONTENT){
        byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
        color = getColorCode(byteIndex, imageData);
        //获取点击 像素点的颜色
        while(y >= 0 && compareColor(ocolor, color, tolerance)){
            y--;
            if(y >= 0){
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
                color = getColorCode(byteIndex, imageData);
            }
        }
        

        // 将顶部的种子点 放入栈中
        if(y >= 0 && !compareColor(ocolor, color, 0)){
            [antiAliasingPoints pushFrontX:x andY:y];
        }
        
        y++;
        
        spanLeft = spanRight = NO;
        
        byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
        
        color = getColorCode(byteIndex, imageData);
        while (y < height && compareColor(ocolor, color, tolerance)){
           //改变旧的颜色
            imageData[byteIndex + 0] = newRed;
            imageData[byteIndex + 1] = newGreen;
            imageData[byteIndex + 2] = newBlue;
            imageData[byteIndex + 3] = newAlpha;
            if(x > 0){
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x - 1) * bytesPerPixel;
                color = getColorCode(byteIndex, imageData);
                if(!spanLeft && x > 0 && compareColor(ocolor, color, tolerance)){
                    [points pushFrontX:(x - 1) andY:y];
                    spanLeft = YES;
                }else if(spanLeft && x > 0 && !compareColor(ocolor, color, tolerance)){
                    spanLeft = NO;
                }
                
                // we can't go left. Add the point on the antialiasing list
                if(!spanLeft && x > 0 && !compareColor(ocolor, color, tolerance) && !compareColor(ncolor, color, tolerance)){
                    [antiAliasingPoints pushFrontX:(x - 1) andY:y];
                }
            }
            if(x < width - 1){
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x + 1) * bytesPerPixel;;
                color = getColorCode(byteIndex, imageData);
                if(!spanRight && compareColor(ocolor, color, tolerance)){
                    [points pushFrontX:(x + 1) andY:y];
                    
                    spanRight = YES;
                }else if(spanRight && !compareColor(ocolor, color, tolerance)){
                    spanRight = NO;
                }
                // we can't go right. Add the point on the antialiasing list
                if(!spanRight && !compareColor(ocolor, color, tolerance) && !compareColor(ncolor, color, tolerance)){
                    [antiAliasingPoints pushFrontX:(x + 1) andY:y];
                }
            }
            y++;
            
            if(y < height){
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;

                color = getColorCode(byteIndex, imageData);
            }
        }
        
        if (y<height){
            byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
            color = getColorCode(byteIndex, imageData);

            if (!compareColor(ocolor, color, 0))
                [antiAliasingPoints pushFrontX:x andY:y];
        }
    }
    
    unsigned int antialiasColor = getColorCodeFromUIColor(newColor,bitmapInfo&kCGBitmapByteOrderMask );
    int red1   = ((0xff000000 & antialiasColor) >> 24);
    int green1 = ((0x00ff0000 & antialiasColor) >> 16);
    int blue1  = ((0x0000ff00 & antialiasColor) >> 8);
    int alpha1 =  (0x000000ff & antialiasColor);
    
    while ([antiAliasingPoints popFront:&x andY:&y] != INVALID_NODE_CONTENT)
    {
        byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
        color = getColorCode(byteIndex, imageData);

        if (!compareColor(ncolor, color, 0))
        {
            int red2   = ((0xff000000 & color) >> 24);
            int green2 = ((0x00ff0000 & color) >> 16);
            int blue2 = ((0x0000ff00 & color) >> 8);
            int alpha2 =  (0x000000ff & color);
            
            if (antiAlias) {
                imageData[byteIndex + 0] = (red1 + red2) / 2;
                imageData[byteIndex + 1] = (green1 + green2) / 2;
                imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
            } else {
                imageData[byteIndex + 0] = red2;
                imageData[byteIndex + 1] = green2;
                imageData[byteIndex + 2] = blue2;
                imageData[byteIndex + 3] = alpha2;
            }
            
            
        }
        
        // left
        if (x>0)
        {
            byteIndex = (bytesPerRow * roundf(y)) + roundf(x - 1) * bytesPerPixel;
            color = getColorCode(byteIndex, imageData);

            if (!compareColor(ncolor, color, 0))
            {
                int red2   = ((0xff000000 & color) >> 24);
                int green2 = ((0x00ff0000 & color) >> 16);
                int blue2 = ((0x0000ff00 & color) >> 8);
                int alpha2 =  (0x000000ff & color);
                
                if (antiAlias) {
                    imageData[byteIndex + 0] = (red1 + red2) / 2;
                    imageData[byteIndex + 1] = (green1 + green2) / 2;
                    imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                    imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                } else {
                    imageData[byteIndex + 0] = red2;
                    imageData[byteIndex + 1] = green2;
                    imageData[byteIndex + 2] = blue2;
                    imageData[byteIndex + 3] = alpha2;
                }
            }
        }
        if (x<width)
        {
            byteIndex = (bytesPerRow * roundf(y)) + roundf(x + 1) * bytesPerPixel;
            color = getColorCode(byteIndex, imageData);

            if (!compareColor(ncolor, color, 0))
            {
                int red2   = ((0xff000000 & color) >> 24);
                int green2 = ((0x00ff0000 & color) >> 16);
                int blue2 = ((0x0000ff00 & color) >> 8);
                int alpha2 =  (0x000000ff & color);
                
                if (antiAlias) {
                    imageData[byteIndex + 0] = (red1 + red2) / 2;
                    imageData[byteIndex + 1] = (green1 + green2) / 2;
                    imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                    imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                } else {
                    imageData[byteIndex + 0] = red2;
                    imageData[byteIndex + 1] = green2;
                    imageData[byteIndex + 2] = blue2;
                    imageData[byteIndex + 3] = alpha2;
                }
                
            }
            
        }
        
        if (y>0)
        {
            byteIndex = (bytesPerRow * roundf(y - 1)) + roundf(x) * bytesPerPixel;
            color = getColorCode(byteIndex, imageData);

            if (!compareColor(ncolor, color, 0))
            {
                int red2   = ((0xff000000 & color) >> 24);
                int green2 = ((0x00ff0000 & color) >> 16);
                int blue2 = ((0x0000ff00 & color) >> 8);
                int alpha2 =  (0x000000ff & color);
                
                if (antiAlias) {
                    imageData[byteIndex + 0] = (red1 + red2) / 2;
                    imageData[byteIndex + 1] = (green1 + green2) / 2;
                    imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                    imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                } else {
                    imageData[byteIndex + 0] = red2;
                    imageData[byteIndex + 1] = green2;
                    imageData[byteIndex + 2] = blue2;
                    imageData[byteIndex + 3] = alpha2;
                }
                
            }
        }
        
        if (y<height)
        {
            byteIndex = (bytesPerRow * roundf(y + 1)) + roundf(x) * bytesPerPixel;
            color = getColorCode(byteIndex, imageData);

            if (!compareColor(ncolor, color, 0))
            {
                int red2   = ((0xff000000 & color) >> 24);
                int green2 = ((0x00ff0000 & color) >> 16);
                int blue2 = ((0x0000ff00 & color) >> 8);
                int alpha2 =  (0x000000ff & color);
                
                if (antiAlias) {
                    imageData[byteIndex + 0] = (red1 + red2) / 2;
                    imageData[byteIndex + 1] = (green1 + green2) / 2;
                    imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                    imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                } else {
                    imageData[byteIndex + 0] = red2;
                    imageData[byteIndex + 1] = green2;
                    imageData[byteIndex + 2] = blue2;
                    imageData[byteIndex + 3] = alpha2;
                }
                
            }
            
        }
    }
    
    //Convert Flood filled image row data back to UIImage object.

    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    self.image = [UIImage imageWithCGImage:newCGImage scale:self.image.scale orientation:UIImageOrientationUp];
     [self revokePointsWith:tapPoint];
    CGImageRelease(newCGImage);
    CGContextRelease(context);
    free(imageData);
}


unsigned int getColorCode (unsigned int byteIndex, unsigned char *imageData)
{
    unsigned int red   = imageData[byteIndex];
    unsigned int green = imageData[byteIndex + 1];
    unsigned int blue  = imageData[byteIndex + 2];
    unsigned int alpha = imageData[byteIndex + 3];
    
    return (red << 24) | (green << 16) | (blue << 8) | alpha;
}
bool compareColor (unsigned int color1, unsigned int color2, int tolorance)
{
    if(color1 == color2){
        return true;
    }
    int red1   = ((0xff000000 & color1) >> 24);
    int green1 = ((0x00ff0000 & color1) >> 16);
    int blue1  = ((0x0000ff00 & color1) >> 8);
    int alpha1 =  (0x000000ff & color1);
    
    int red2   = ((0xff000000 & color2) >> 24);
    int green2 = ((0x00ff0000 & color2) >> 16);
    int blue2  = ((0x0000ff00 & color2) >> 8);
    int alpha2 =  (0x000000ff & color2);
    
    int diffRed   = abs(red2   - red1);
    int diffGreen = abs(green2 - green1);
    int diffBlue  = abs(blue2  - blue1);
    int diffAlpha = abs(alpha2 - alpha1);
    
    if( diffRed   > tolorance ||
       diffGreen > tolorance ||
       diffBlue  > tolorance ||
       diffAlpha > tolorance  )
    {
        return false;
    }
    
    return true;
}

unsigned int getColorCodeFromUIColor(UIColor *color, CGBitmapInfo orderMask)
{
    //Convert newColor to RGBA value so we can save it to image.
    int newRed, newGreen, newBlue, newAlpha;
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    if(CGColorGetNumberOfComponents(color.CGColor) == 2)
    {
        newRed   = newGreen = newBlue = components[0] * 255;
        newAlpha = components[1] * 255;
    }
    else if (CGColorGetNumberOfComponents(color.CGColor) == 4)
    {
        if (orderMask == kCGBitmapByteOrder32Little)
        {
            newRed   = components[2] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[0] * 255;
            newAlpha = 255;
        }
        else
        {
            newRed   = components[0] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[2] * 255;
            newAlpha = 255;
        }
    }
    else
    {
        newRed   = newGreen = newBlue = 0;
        newAlpha = 255;
    }
    
    unsigned int ncolor = (newRed << 24) | (newGreen << 16) | (newBlue << 8) | newAlpha;
    
    return ncolor;
}
//- (UIColor *)colorAtPixel:(CGPoint)point {
//    // Cancel if point is outside image coordinates
//    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height), point)) {
//        return nil;
//    }
//    
//    NSInteger pointX = trunc(point.x);
//    NSInteger pointY = trunc(point.y);
//    CGImageRef cgImage = self.baseimage.CGImage;
//    NSUInteger width = self.baseimage.size.width;
//    NSUInteger height = self.baseimage.size.height;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    int bytesPerPixel = 4;
//    int bytesPerRow = bytesPerPixel * 1;
//    NSUInteger bitsPerComponent = 8;
//    unsigned char pixelData[4] = { 0, 0, 0, 0 };
//    CGContextRef context = CGBitmapContextCreate(pixelData,
//                                                 1,
//                                                 1,
//                                                 bitsPerComponent,
//                                                 bytesPerRow,
//                                                 colorSpace,
//                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    CGColorSpaceRelease(colorSpace);
//    CGContextSetBlendMode(context, kCGBlendModeCopy);
//    
//    // Draw the pixel we are interested in onto the bitmap context
//    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
//    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
//    CGContextRelease(context);
//    
//    // Convert color values [0..255] to floats [0.0..1.0]
//    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
//    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
//    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
//    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
//    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
//}
-(void)setNewcolor:(UIColor *)newcolor
{
    _newcolor = newcolor;
    if (_newcolor == [UIColor blackColor]) {
        _newcolor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:1];

    }
}
- (void)revokePointsWith:(CGPoint )point {
     self.lastPoint = point;
    BOOL isadd = YES;
    for (NSNumber *pointNum in self.revokePoints) {
        CGPoint savePoint = [pointNum CGPointValue];
        if ( savePoint.x == point.x && savePoint.y == point.y) {
            isadd = NO;
            [self.revokePoints removeObject:pointNum];
            break;
        }
    }
    if (isadd) {
        [self.revokePoints addObject:@(point)];
    }
    
    if (self.revokePoints.count == 0) {
         [_revokePoints addObject:@(point)];
    }
   
}
- (NSMutableArray *)revokePoints {
    if (!_revokePoints) {
         _revokePoints = [NSMutableArray array];
    }
    return _revokePoints;
}
@end
