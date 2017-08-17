//
//  ViewController.m
//  YQDisplayPhotoContainerView
//
//  Created by 俞琦 on 2017/8/10.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "ViewController.h"
#import "YQDisplayPhotoContainerView.h"

@class YQTableViewCell;
@protocol YQTableViewCellDelegate <NSObject>
- (void)cellImageViewDidTap:(YQDisplayPhotoContainerView *)displayView cell:(YQTableViewCell *)cell tapImageView:(UIImageView *)tapImageView tapIndex:(int)tapIndex;
@end

@interface YQTableViewCell : UITableViewCell <YQDisplayViewDelegate>
@property (nonatomic, weak) UILabel *label;  ///<这一行有%ld个图片
@property (nonatomic, weak) YQDisplayPhotoContainerView *displayView;  ///<图片展示器
@property (nonatomic, strong) NSArray *photoArray; ///<图片数组
@property (nonatomic, weak) id <YQTableViewCellDelegate> delegate;
@end



@implementation YQTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(0, 0, 300, 40);
        [self addSubview:label];
        self.label = label;
        
        
        YQDisplayPhotoContainerView *display = [[YQDisplayPhotoContainerView alloc] initWithFrame:CGRectMake(0, 40, 300, 0) delegate:self];
        [self addSubview:display];
        self.displayView = display;
    }
    return self;
}

- (void)setPhotoArray:(NSArray *)photoArray
{
    _photoArray = photoArray;
    
    self.label.text = [NSString stringWithFormat:@"这一行有%ld个图片", photoArray.count];
    CGFloat height = [YQDisplayPhotoContainerView heightForWidth:300 photoArray:photoArray];
    
    CGRect frame = self.displayView.frame;
    frame.size.height = height;
    self.displayView.frame = frame;
    self.displayView.photoArray = photoArray;
}

#pragma mark - YQDisplayViewDelegate // 一层层传递回控制器 用的都是代理
- (void)imageViewDidTap:(YQDisplayPhotoContainerView *)displayView tapImageView:(UIImageView *)tapImageView tapIndex:(int)tapIndex
{
    if ([self.delegate respondsToSelector:@selector(cellImageViewDidTap:cell:tapImageView:tapIndex:)]) {
        [self.delegate cellImageViewDidTap:displayView cell:self tapImageView:tapImageView tapIndex:tapIndex];
    }
}

@end


@interface ViewController () <UITableViewDelegate, UITableViewDataSource, YQTableViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [self getData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[YQTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.photoArray = self.listArray[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [YQDisplayPhotoContainerView heightForWidth:300 photoArray:self.listArray[indexPath.row]] + 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)getData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"imageSource.json" ofType:@""];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSMutableArray *photoArray = [NSMutableArray array];
    [dic[@"pic_infos"] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *photoDic = obj;

        YQPhotoMetaData *bmiddle = [[YQPhotoMetaData alloc] initWithPicDic:photoDic[@"large"]];
        YQPhotoMetaData *original = [[YQPhotoMetaData alloc] initWithPicDic:photoDic[@"original"]];
        YQPhoto *photo = [[YQPhoto alloc] init];
        
        photo.picID = photoDic[@"pic_id"];
        photo.bmiddle = bmiddle;
        photo.original = original;
        
        [photoArray addObject:photo];
    }];
    
    
    for (int i = 0; i<100; i++) {
        int count = arc4random() % 10;
        if (count == 0) count ++;
        NSArray *array = [photoArray subarrayWithRange:NSMakeRange(0, count)];
        [self.listArray addObject:array];
    }
    
    self.title = [NSString stringWithFormat:@"一共%ld行", self.listArray.count];
    [self.tableView reloadData];
}

- (NSMutableArray *)listArray
{
    if (!_listArray) {
        _listArray = [NSMutableArray array];
    }
    return _listArray;
}

#pragma mark - YQTableViewCellDelegate
- (void)cellImageViewDidTap:(YQDisplayPhotoContainerView *)displayView cell:(YQTableViewCell *)cell tapImageView:(UIImageView *)tapImageView tapIndex:(int)tapIndex
{
    
}

@end
