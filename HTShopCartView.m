//
//  HTShopCartView.m
//  Test
//
//  Created by HengtaoDai on 16/9/28.
//  Copyright © 2016年 HYcompany. All rights reserved.
//

#import "HTShopCartView.h"
#import "ProductBean.h"
#import "CounterView.h"
#import "HTCounter.h"
#import "HTSizeView.h"

static const CGFloat kAnimateDuration = 0.5;        //动画持续时间
#define fHEIGHT 70.0/568*G_SCREEN_HEIGHT

@interface HTShopCartView () <HTSizeViewDelegate>
{
    UIView          *_maskView;
    UIView          *_whiteView;
    UIImageView     *_imgProduct;   //商品图片
    UIButton        *_btnClose;     //关闭按钮
    UILabel         *_lblInfo;      //图片右侧label
    UIScrollView    *_mainScrollview; //滚动规格视图
    HTCounter       *_counter;      //数量加减器
    HT_CARTBLOCK    _block;
}
@end


@implementation HTShopCartView

- (id)initWithFrame:(CGRect)frame andBlock:(HT_CARTBLOCK)block
{
    if (self = [super initWithFrame:frame])
    {
        _block = block;
        //遮罩图
        _maskView = [[UIView alloc] initWithFrame:frame];
        _maskView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
        [self addSubview:_maskView];
        
        //白板 100 + i*fHEIGHT + 42 + 80
        NSInteger iRowOfSize = 3;
        CGFloat height = 100 + iRowOfSize*fHEIGHT + 42 + 80;
        _whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, _maskView.height, frame.size.width, height)];
        _whiteView.backgroundColor = [UIColor whiteColor];
        [_maskView addSubview:_whiteView];
        
        //白板上方的透明视图
        CGFloat heightOfTop = _maskView.height - _whiteView.height;
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _maskView.width, heightOfTop)];
        topView.backgroundColor = [UIColor clearColor];
        [topView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMask)]];
        [_maskView insertSubview:topView belowSubview:_whiteView];
        
        //商品图片
        _imgProduct = [[UIImageView alloc] initWithFrame:CGRectMake(10, -25, 120, 120)];
        _imgProduct.backgroundColor = [UIColor whiteColor];
        _imgProduct.layer.cornerRadius = 6;
        _imgProduct.layer.masksToBounds = YES;
        _imgProduct.layer.borderColor = RGBCOLOR(220, 220, 220).CGColor;
        _imgProduct.layer.borderWidth = 0.7;
        [_whiteView addSubview:_imgProduct];
        _imgProduct.image = [UIImage imageNamed:@"default_pro"];
        
        //图片右侧label 10+85
        _lblInfo = [[UILabel alloc] initWithFrame:CGRectMake(_imgProduct.right+10, 10, _whiteView.width-120-10*2-40, 85)];
        _lblInfo.numberOfLines = 0;
        _lblInfo.font = [UIFont systemFontOfSize:14];
        [_whiteView addSubview:_lblInfo];
        
        //关闭按钮
        _btnClose = [[UIButton alloc] initWithFrame:CGRectMake(_lblInfo.right, 0, 40, 40)];
        [_btnClose setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_btnClose addTarget:self action:@selector(closeMask) forControlEvents:UIControlEventTouchUpInside];
        [_whiteView addSubview:_btnClose];
        
        //分割线
        UIView *hxLine1 = [[UIView alloc]initWithFrame:CGRectMake(10, 100, _whiteView.width-10, 1)];
        hxLine1.backgroundColor = RGBCOLOR(240, 240, 240);
        [_whiteView addSubview:hxLine1];
        
        //有的商品尺码和颜色分类特别多 所以用UIScrollView 分类过多显示不全的时候可滑动查看
        _mainScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(10, hxLine1.bottom, _whiteView.width-15, iRowOfSize*fHEIGHT+42+18)];
        _mainScrollview.showsHorizontalScrollIndicator = NO;
        [_whiteView addSubview:_mainScrollview];
        
        //取消、订购按钮
        for (int i = 0; i < 2; i++)
        {
            CGFloat width = (_whiteView.width - 30)/2;
            CGFloat left = i == 0? -width-5 : 5;
            
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(_whiteView.width/2+left, _mainScrollview.bottom, width, 44)];
            [btn setTitle: i==0 ? @"取消": @"订购" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setBackgroundColor: i==0? [UIColor whiteColor]: G_NAV_COLOR];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            btn.layer.cornerRadius = 4;
            btn.layer.borderWidth = 1;
            btn.tag = 100+i;
            btn.layer.borderColor = G_NAV_COLOR.CGColor;
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_whiteView addSubview:btn];
        }
        
        //动画
        [UIView animateWithDuration:kAnimateDuration animations:^{
            CGRect frame = _whiteView.frame;
            frame.origin.y = _maskView.height - height;
            _whiteView.frame = frame;
            
        } completion:nil];
        
    }
    
    return self;
}


#pragma mark - setter方法
- (void)setArrSizeData:(nullable NSArray *)arrSizeData
{
    if (!arrSizeData)
    {
        //读取plist文件
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"sizes" ofType:@"plist"];
        arrSizeData = [[NSMutableArray alloc]initWithContentsOfFile:plistPath];
    }
    
    CGFloat top = 0;
    
    for (int i = 0; i < arrSizeData.count; i++)
    {
        HTSizeView *sizeView = [[HTSizeView alloc] initWithFrame:CGRectMake(0, top, _mainScrollview.width, fHEIGHT)];
        sizeView.dicSize = arrSizeData[i];
        sizeView.delegate = self;
        sizeView.iRow = i;
        sizeView.frame = CGRectMake(0, top, _mainScrollview.width, sizeView.fHeight);
        [_mainScrollview addSubview:sizeView];
        
        top += sizeView.fHeight;
    }
    
    UIView *hxLine2 = [[UIView alloc]initWithFrame:CGRectMake(0, top, _mainScrollview.width, 1)];
    hxLine2.backgroundColor = RGBCOLOR(240, 240, 240);
    [_mainScrollview addSubview:hxLine2];
    
    //购买数量
    UILabel *lblBuyNum = [[UILabel alloc]initWithFrame:CGRectMake(10, hxLine2.bottom, 90, 42)];
    lblBuyNum.text = @"购买数量";
    lblBuyNum.textColor = [UIColor blackColor];
    lblBuyNum.font = [UIFont systemFontOfSize:14];
    [_mainScrollview addSubview:lblBuyNum];
    
    //加减器
    _counter = [[HTCounter alloc] initWithFrame:CGRectMake(_mainScrollview.width-110, lblBuyNum.top+6, 100, 30)];
    _counter.editable = NO;
    [_mainScrollview addSubview:_counter];
    
    UIView *hxLine3 = [[UIView alloc]initWithFrame:CGRectMake(0, hxLine2.bottom+42, _mainScrollview.width, 1)];
    hxLine3.backgroundColor = RGBCOLOR(240, 240, 240);
    [_mainScrollview addSubview:hxLine3];
    
    _mainScrollview.contentSize = CGSizeMake(_mainScrollview.width, top+43+18);
    
    NSString *strName = @"小熊（Bear）加湿器";
    NSString *strPrice = @"\n¥159.00";
    NSString *strStock = @"\n库存800件";
    _lblInfo.text = [NSString stringWithFormat:@"%@%@%@",strName,strPrice,strStock];
    _lblInfo.textColor = [UIColor blackColor];
    _lblInfo.font = [UIFont systemFontOfSize:13];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 5;
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:_lblInfo.text];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(strName.length, strPrice.length)];
    [AttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, strName.length)];
    [AttributedStr addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, _lblInfo.text.length)];
    _lblInfo.attributedText = AttributedStr;
}


- (void)setIMinValue:(NSInteger)iMinValue
{
    _counter.iMinValue = iMinValue;
}


- (void)setIMaxValue:(NSInteger)iMaxValue
{
    _counter.iMaxValue = iMaxValue;
}


- (void)closeMask
{
    [UIView animateWithDuration:kAnimateDuration animations:^{
        CGRect frame = _whiteView.frame;
        frame.origin.y = G_SCREEN_HEIGHT+25;
        _whiteView.frame = frame;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#define mark - 点击事件
- (void)btnClick:(UIButton *)btn
{
    _block(btn.tag - 100);
    
    [self closeMask];
}


- (void)selectBtnInRow:(NSUInteger)iRow andIndex:(NSUInteger)index
{
    NSLog(@"--> row:%ld, index:%ld",iRow,index);
}



- (float)widthForText:(NSString *)text fontSize:(float)fontSize
{
    CGSize constraint = CGSizeMake(400.0f, 30.0f);
    
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    CGRect rect = [attributedText boundingRectWithSize:constraint
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    return size.width;
}


@end
