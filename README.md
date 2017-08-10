# YQDisplayPhotoContainerView
类似微博首页的图片展示器


这篇文章本来应该上个礼拜就可以发布，但是由于在写一个轻量级的SD，因此耽搁了很久，毕竟这个小轮子要和图片下载缓存器一起使用才能看到效果。

# 一、效果：

![效果.gif](http://upload-images.jianshu.io/upload_images/2312304-3bc96b08f091cb20.gif?imageMogr2/auto-orient/strip)

# 二、思路
### 首先
一般这种图片展示器都是用在TimeLine的cell上的，cell的高度往往随着cell的内容改变而改变。因此我认为该控件提供一个方法来返回控件自身的高度是很必要的。这样使用的人就可以直接调用方法来获得高度，至于到底如何算出，就与使用者无关了。
```
/**
 类方法，用来计算该视图的高度 和photoArray的个数 有关
 
 @param width           width.
 @param photoArray      图片数组
 */
+ (CGFloat)heightForWidth:(CGFloat)width photoArray:(NSArray *)photoArray;
```
### 其次
视图内的imageView的排布是与传递过去的photoArray相关。自然需要给视图一个公开的``photoArray``属性。这样使用者直接设置``photoArray``就行。
当然，我会重写`` - (void)setPhotoArray:(NSArray *)photoArray``来进行子控件排布，但是使用者就没必要知道了。毕竟轻松留给他人。
```
@property (nonatomic, strong) NSArray *photoArray;     ///<YQPhoto类型的数组
```
### 最后
``photoArray``里面放什么东西是需要定下来的，总不能乱传吧。因此我创建了``YQPhoto ``和``YQPhotoMetaData ``类。
```
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

@interface YQPhoto : NSObject   ///<YQPhoto 数组内就是一个个YQPhoto 每一个YQPhoto中都有一个缩略图和一个原始图以及照片id
@property (nonatomic, strong)YQPhotoMetaData *bmiddle;  ///<缩略图
@property (nonatomic, strong)YQPhotoMetaData *original; ///<原始图
@property (nonatomic, copy) NSString *picID;  /// 照片id
@end
```

也许你看到这里会有点乱，我还是画一张图片吧。

![结构图.jpeg](http://upload-images.jianshu.io/upload_images/2312304-04b2ef95ffcf7c23.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

就像图片上写的，高宽比还有类型是需要自己算的，所以``YQPhotoMetaData``自定义了初始化方法`` - (instancetype)initWithPicDic:(NSDictionary *)picDic;``。 这样直接可以获得``YQPhotoMetaData``的对象了。
```
- (instancetype)initWithPicDic:(NSDictionary *)picDic
{
    self = [super init];
    self.url = picDic[@"url"];
    self.height = [picDic[@"height"] intValue];
    self.width = [picDic[@"width"] intValue];
    self.scale = (CGFloat)self.height / self.width;
    if (self.scale > 2) {
        self.photoType = YQPhotoTypeLong; // 长图
    } else if (self.scale < 1) {
        self.photoType = YQPhotoTypeHorizontal;
    }
    return self;
}
```

这里补充一点，在平时开发中，需要初始化对象的时候，也同样可以自定义初始化方法``init...``，顺便传值，这样就可以直接在这个方法中把一些复杂的属性给赋值了。
# 三、使用
### 获得数据
获得数据的代码比较繁琐，我就不全部贴出来了。总之，我获得了一个内含9个YQphoto对象的数组`` photoArray``，然后循环100次，随机的截取`` photoArray``，最后添加到``self.listArray``里面。
```
for (int i = 0; i<100; i++) {
        int count = arc4random() % 10;
        if (count == 0) count ++;
        NSArray *array = [photoArray subarrayWithRange:NSMakeRange(0, count)];
        [self.listArray addObject:array];
}
```

![数组内部1.png](http://upload-images.jianshu.io/upload_images/2312304-dfcf5f8ad1d4a3f4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![数组内部2.png](http://upload-images.jianshu.io/upload_images/2312304-5693e800d3c1038f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![数组内部3.png](http://upload-images.jianshu.io/upload_images/2312304-857539e5d2887001.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![数组内部4.png](http://upload-images.jianshu.io/upload_images/2312304-35e9c896bd7584fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![数组内部5.png](http://upload-images.jianshu.io/upload_images/2312304-11066d03f99570d7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 自定义 YQTableViewCell
放一下属性：
```
@interface YQTableViewCell : UITableViewCell
@property (nonatomic, weak) UILabel *label;  ///<这一行有%ld个图片
@property (nonatomic, weak) YQDisplayPhotoContainerView *displayView;  ///<图片展示器
@property (nonatomic, strong) NSArray *photoArray; ///<图片数组
@end
```
没什么好说的，比较简单，重写`` - (void)setPhotoArray:(NSArray *)photoArray``设置内容就行。

### 设置tableview
```
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
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [YQDisplayPhotoContainerView heightForWidth:300 photoArray:self.listArray[indexPath.row]] + 40;
}

```
关键在于``- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath ``方法。
高度是通过最前面提到的计算高度方法获得的。这里的``+40``是因为``UILabel *label``也有高度。前者只是图片展示器的高度而并不已经是cell的高度了。

#补充
最后再提一些要点。
如果你有兴趣去看内部实现的话，你会发现在这个视图内部我创建了一个 尺寸计算器`` YQSizeCalculator``。所有的计算尺寸的方法都在这个计算机内部实现，这样当你要有新的设计排布时，更改计算机内部的计算方式，就可以获得你要的尺寸。

里面还有一个小细节，当放入不同的长图和横图时，视图的高度和内部的imageview的frame 也会不一样，如果有兴趣也可以自己去尝试呀。

放一下项目文件结构，很简单哟。

![项目文件结构.png](http://upload-images.jianshu.io/upload_images/2312304-4ce8a17d812e4f7c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


# 代码
[github：YQDisplayPhotoContainerView](https://github.com/JabberYQ/YQDisplayPhotoContainerView)

#结束
最后的最后再放一个彩蛋，效果图可以看到所有图片都是占位图，那是因为在设置内部imageView的image时写死了。
```
imageView.image = [UIImage imageNamed:@"placeholder"];
```
下一篇等我写出了轻量级的SD后，再把这行代码改掉。
