//
//  HTShopCartView.h
//  Test
//
//  Created by HengtaoDai on 16/9/28.
//  Copyright © 2016年 HYcompany. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HT_CARTBLOCK)(NSInteger btnIndex);


@interface HTShopCartView : UIView

@property (nonatomic, strong) NSArray *arrSizeData;   //型号数组
@property (nonatomic, assign) NSInteger iMinValue;    //最小的购买数，默认为1
@property (nonatomic, assign) NSInteger iMaxValue;    //最大的购买数，默认为无限

/**
 初始化

 @param frame frame
 @param block 点击底部按钮回调方法 bottom btns action
 
 @return
 */
- (id)initWithFrame:(CGRect)frame andBlock:(HT_CARTBLOCK)block;


/**
 关闭视图（动画）
 */
- (void)closeMask;

@end
