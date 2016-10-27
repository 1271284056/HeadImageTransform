//
//  TransformerHeaderController.m
//  顶部放大
//
//  Created by 张江东 on 16/10/27.
//  Copyright © 2016年 58kuaipai. All rights reserved.
//

#import "TransformerHeaderController.h"
#import "UIView+Extension.h"
#import "UIColor+Hex.h"
#import "UIImageView+WebCache.h"


static NSString *kCellId = @"cellId";
#define kHeaderHeight 200

@interface TransformerHeaderController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation TransformerHeaderController{
    UIView* _headerView;
    UIImageView* _headerImageView;
    UIView* _lineView;
    UIStatusBarStyle _statusBarStyle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self prepareTableView];
    [self prepareHeaderView];
    
    _statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 取消自动调整滚动视图间距 - ViewController + NAV 会自动调整 tableView 的 contentInset 要不顶部视图和cell会有一条空隙
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _statusBarStyle;
}

///  准备顶部视图
- (void)prepareHeaderView
{
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.widthS, kHeaderHeight)];
    
    _headerView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    
    [self.view addSubview:_headerView];
    
    // cmd+shift+e
    _headerImageView = [[UIImageView alloc] initWithFrame:_headerView.bounds];
    _headerImageView.backgroundColor = [UIColor colorWithHex:0x000033];
    
    // 设置 contentMode
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    // 设置图像裁切
    _headerImageView.clipsToBounds = YES;
    
    [_headerView addSubview:_headerImageView];
    
    // 添加分隔线 一个像素点
    CGFloat lineHeight = 1 / [UIScreen mainScreen].scale;
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderHeight - lineHeight, _headerView.widthS, lineHeight)];
    _lineView.backgroundColor = [UIColor lightGrayColor];
    
    [_headerView addSubview:_lineView];
    
    // 设置图像
    NSURL* url = [NSURL URLWithString:@"http://img.woyaogexing.com/2016/10/24/0d5d568c5425039b!600x600.jpg"];
    [_headerImageView sd_setImageWithURL:url];
}

- (void)prepareTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellId];
    
    [self.view addSubview:tableView];
    
    // 设置表格的间距
    tableView.contentInset = UIEdgeInsetsMake(kHeaderHeight, 0, 0, 0);
    // 设置滚动条从y值200处开始显示 要不会从顶部显示
    tableView.scrollIndicatorInsets = tableView.contentInset;
}

#pragma UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    

    cell.textLabel.text = @(indexPath.row).stringValue;
    
    return cell;
}

//滚动视图时候
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    // offset < 0 往下滑动 >0往上滑动
    CGFloat offset = scrollView.contentOffset.y + scrollView.contentInset.top;
//        NSLog(@"%f %f %f", offset,scrollView.contentOffset.y,scrollView.contentInset.top);
    
    // 放大 往下滑动
    if (offset <= 0) {
        // 调整 headView 顶部置顶 高度变大
        _headerView.y = 0;
        _headerView.heightS = kHeaderHeight - offset;
        _headerImageView.alpha = 1;
    }
    else {
        // 整体移动 网上滑动 变小
        _headerView.heightS = kHeaderHeight;
        
        // headerView 最小 y 值 让移动到剩64时候不能往上移动
        CGFloat min = kHeaderHeight - 64;
        _headerView.y = -MIN(min, offset);
        
        // 设置透明度
//         NSLog(@"%f", offset / min);
        // 根据输出可以知道 offset / min == 1 时候为上移剩余64时
        CGFloat progress = 1 - (offset / min);
        _headerImageView.alpha = progress;
        
        // 根据透明度，来修改状态栏的颜色 <0.5时候往上移动
        _statusBarStyle = (progress < 0.5) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
        // 主动更新状态栏
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
    }
    
    // 设置图像高度
    _headerImageView.heightS = _headerView.heightS;
    // 设置分隔线的位置
    _lineView.y = _headerView.heightS - _lineView.heightS;
}@end
