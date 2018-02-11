//
//  MyimageView.h
//  TextHuaTu
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2018/1/29.
//  Copyright © 2018年 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MyimageView : UIImageView
/*
 记录 开始时候的图片 就是为填充时候图片
 **/
@property (nonatomic,copy) UIImage *baseimage;
/*
当前需要填充的颜色
 **/
@property (nonatomic,strong) UIColor  *newcolor;
/** 多个撤销点 */
@property(nonatomic , strong)NSMutableArray  *revokePoints;
/*
 缩放比例
 **/
@property (nonatomic,assign) CGFloat scaleNum;

/**
 撤销操作
 */
- (void)revokeOption;


@end
