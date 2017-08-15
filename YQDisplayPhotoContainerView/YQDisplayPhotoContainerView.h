//
//  YQDisplayPhotoContainerView.h
//  YQImageExhibition
//
//  Created by 俞琦 on 2017/7/28.
//  Copyright © 2017年 俞琦. All rights reserved.
//  用于展示图片的容易 类似微博cell中的界面

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YQPhotoType) {
    YQPhotoTypeNone = 0,    ///< 正常图片
    YQPhotoTypeHorizontal,  ///< 横图
    YQPhotoTypeLong,        ///< 长图
};

@interface YQPhotoMetaData : NSObject ///<YQPhoto的数据
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) YQPhotoType photoType;
- (instancetype)initWithPicDic:(NSDictionary *)picDic;
@end

@interface YQPhoto : NSObject   ///<YQPhoto
@property (nonatomic, strong)YQPhotoMetaData *bmiddle;
@property (nonatomic, strong)YQPhotoMetaData *original;
@property (nonatomic, copy) NSString *picID;
@end

@class YQDisplayPhotoContainerView;
@protocol YQDisplayViewDelegate <NSObject>
- (void)imageViewDidTap:(YQDisplayPhotoContainerView *)displayView;
@end

@interface YQDisplayPhotoContainerView : UIView
@property (nonatomic, strong) NSArray *photoArray;     ///<YQPhoto类型的数组
@property (nonatomic, weak) id <YQDisplayViewDelegate> delegate;   ///<目标 用于传递点击事件

/**
 实例方法，初始化一个实例
 
 @param frame       位置尺寸.
 @param delegate      目标 用于传递点击事件
 */
- (instancetype)initWithFrame:(CGRect)frame delegate:(id <YQDisplayViewDelegate>)delegate;

/**
 类方法，用来计算该视图的高度 和photoArray的个数 有关
 
 @param width           width.
 @param photoArray      图片数组
 */
+ (CGFloat)heightForWidth:(CGFloat)width photoArray:(NSArray *)photoArray;
@end
