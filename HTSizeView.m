//
//  SizeView.m
//  WaiTanXS
//
//  Created by HengtaoDai on 16/10/9.
//  Copyright © 2016年 HYcompany. All rights reserved.
//

#import "WTSizeView.h"

static const NSString *strSizeName = @"name";   //型号名称
static const NSString *strSizeItems = @"items"; //型号值数组
static const CGFloat kSpaceHorizontal = 10;   //按钮之间的水平方向间隔
static const CGFloat kSpaceVertical = 5;   //按钮之间的垂直方向间隔

@implementation WTSizeView
{
    UILabel     *_lblName;
    UIButton    *_btnPreSelect;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        _lblName.textColor = [UIColor blackColor];
        _lblName.font = [UIFont systemFontOfSize:14];
        [self addSubview:_lblName];
    }
    
    return self;
}


- (void)setDicSize:(NSDictionary *)dicSize
{
    _fHeight = 70;
    
    _lblName.text = dicSize[strSizeName];
    
    NSArray *arrItem = dicSize[strSizeItems];
    
    CGFloat left = 0;   //当前btn到左侧边界的距离
    CGFloat top = 0;    //当前btn到lblName的距离
    NSInteger iRow = 0; //btn的行数
    
    for (int i = 0; i < arrItem.count; i++)
    {
        CGFloat width = [self widthForText:arrItem[i] fontSize:14]; //当前btn的width
        if (left + width > self.width)
        {
            iRow ++;
            left = 0;
            top = (30+kSpaceVertical)*iRow;
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(left, top+_lblName.height, width, 30)];
        [btn setTitle:arrItem[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:RGBCOLOR(240, 240, 240)];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.layer.cornerRadius = 6;
        [btn handleWithControlEvent:UIControlEventTouchUpInside andBlock:^{
            
            if (_btnPreSelect != btn)
            {
                [_btnPreSelect setBackgroundColor:RGBCOLOR(240, 240, 240)];
                [btn setBackgroundColor:G_NAV_COLOR];
                _btnPreSelect = btn;
                
                btn.selected = YES;
                
                if ([self.delegate respondsToSelector:@selector(selectBtnInRow:andIndex:)])
                {
                    [self.delegate selectBtnInRow:_iRow andIndex:i];
                }
            }
            else
            {
                btn.selected = !btn.selected;
                
                if (btn.isSelected)
                {
                    if ([self.delegate respondsToSelector:@selector(selectBtnInRow:andIndex:)])
                    {
                        [self.delegate selectBtnInRow:_iRow andIndex:i];
                    }
                    
                    [btn setBackgroundColor:G_NAV_COLOR];
                    _btnPreSelect = btn;
                }
                else
                {
                    [btn setBackgroundColor:RGBCOLOR(240, 240, 240)];
                }
            }
            
            
        }];
        [self addSubview:btn];
        
        left += width + kSpaceHorizontal;    //距离向后推
    }
    
    _fHeight = _lblName.height + top + 30 + kSpaceVertical; //self的实际高度
}


- (CGFloat)fHeight
{
    return _fHeight;
}


- (CGFloat)widthForText:(NSString *)text fontSize:(float)fontSize
{
    CGSize constraint = CGSizeMake(400.0f, 30.0f);
    
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    CGRect rect = [attributedText boundingRectWithSize:constraint
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    return size.width+20;
}


@end
