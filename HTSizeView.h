//
//  HTSizeView.h
//  Test
//
//  Created by HengtaoDai on 16/10/9.
//  Copyright © 2016年 HYcompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HTSizeViewDelegate <NSObject>

- (void)selectBtnInRow:(NSUInteger)iRow andIndex:(NSUInteger)index;

@end

@interface HTSizeView : UIView

@property (nonatomic, strong) NSDictionary *dicSize;
@property (nonatomic, assign) CGFloat fHeight;
@property (nonatomic, assign) NSUInteger iRow;     //第几个规格
@property (nonatomic, weak) id<HTSizeViewDelegate> delegate;


- (id)initWithFrame:(CGRect)frame;


@end
