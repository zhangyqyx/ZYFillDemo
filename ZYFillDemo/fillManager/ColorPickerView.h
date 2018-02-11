//
//  ColorPickerView.h
//  ZYFillDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2018/1/29.
//  Copyright © 2018年 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPickerViewDelegate <NSObject>

- (void)pickedColor:(UIColor *)color;

@end


@interface ColorPickerView : UIView

/** imageView */
@property(nonatomic , strong) UIImageView  *imgView;
/** 协议 */
@property(nonatomic , weak) id<ColorPickerViewDelegate> pickedColorDelegate;

@end
