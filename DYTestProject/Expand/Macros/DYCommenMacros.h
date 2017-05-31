//
//  DYCommenMacros.h
//  DYTestProject
//
//  Created by ZeroDY on 2017/5/31.
//  Copyright © 2017年 ZeroDY. All rights reserved.
//

#ifndef DYCommenMacros_h
#define DYCommenMacros_h


/** 输出*/
#ifdef DEBUG
#define DYLog(...) NSLog(__VA_ARGS__)
#else
#define DYLog(...)
#endif

#define DYPrint_CurrentMethod DYLog(@"method==> %s",__FUNCTION__);
#define DYPrint_CurrentLine DYLog(@"line==> %d",__LINE__);
#define DYPrint_CurrentClass DYLog(@"class==> %@",__FILE__);
#define DYPrint_CurrentStack DYLog(@"%@",[NSThread callStackSymbols]);
#define DYPrint_CurrentPath DYLog(@"%s",__FILE__);
#define DYPrint_CurrentDetail DYLog(@"class==> %@, method==> %s, line==> %d",[self class],__FUNCTION__,__LINE__);


/** 字体*/
#define DYFont(x) [UIFont systemFontOfSize:x]
#define DYBoldFont(x) [UIFont boldSystemFontOfSize:x]
#define DYNewFont(NAME,FONTSIZE) [UIFont fontWithName:(NAME)size:(FONTSIZE)]

/** 颜色*/
#define DYRGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define DYRGBAColor(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define DYRGB16Color(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define DYRandomColorKRGBColor (arc4random_uniform(256)/255.0,arc4random_uniform(256)/255.0,arc4random_uniform(256)/255.0)//随机色生成


/** 获取硬件信息*/
#define DYSCREEN_W [UIScreen mainScreen].bounds.size.width
#define DYSCREEN_H [UIScreen mainScreen].bounds.size.height
#define DYCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])
#define DYCurrentSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]

/** 获取系统对象*/
#define kDYApplication [UIApplication sharedApplication]
#define kDYAppWindow [UIApplication sharedApplication].delegate.window
#define kDYAppDelegate [AppDelegate shareAppDelegate]
#define kDYRootViewController [UIApplication sharedApplication].delegate.window.rootViewController
#define kDYUserDefaults [NSUserDefaults standardUserDefaults]
#define kDYNotificationCenter [NSNotificationCenter defaultCenter]

#if TARGET_OS_IPHONE  //真机
#endif  
#if TARGET_IPHONE_SIMULATOR  //模拟器
#endif


/** 适配*/
#define DYiOS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define DYiOS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define DYiOS_9_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define DYiOS_10_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

#define DYiPhone4_OR_4s    (DYSCREEN_H == 480)
#define DYiPhone5_OR_5c_OR_5s_se  (DYSCREEN_H == 568)
#define DYiPhone6_OR_6s_7   (DYSCREEN_H == 667)
#define DYiPhonePlus   (DYSCREEN_H == 736)
#define DYiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/** 弱指针*/
#define DYWeakSelf(weakSelf) __weak __typeof(&*self)weakSelf = self;

/** 加载本地文件*/
#define DYImageNamed(name) [UIImage imageNamed:name]
#define DYLoadImage(file,type) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:type]]
#define DYLoadArray(file,type) [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:type]]
#define DYLoadDict(file,type) [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:type]]

/** 快速进入一个bundle的宏*/
#define DYBundle(bundleName) [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:(bundleName) withExtension:@"bundle"]]

/** 加载bundle内nib或图片*/
// 这里返回的是一个nib内的元素
#define DYLoadBundleNib(bundleName,nibName,index) [DYBundle(bundleName) loadNibNamed:(nibName) owner:nil options:nil][(index)];
// 这里返回的是包装后的图片名
#define DYBundleImgName(bundleName,iconName) (iconName)?[[NSString stringWithFormat:@"%@.bundle/",((bundleName))] stringByAppendingString:(iconName)]:(iconName)

/** 裁切图片的宏*/
#define MTBStretchImg(image) [(image) stretchableImageWithLeftCapWidth:(image.size.width/3.0) topCapHeight:image.size.height/3.0]?:[UIImage new]
#define MTBStretchImgCustom(image,w,h) [(image) stretchableImageWithLeftCapWidth:(image.size.width*(w)) topCapHeight:image.size.height*(h)]?:[UIImage new]

/**View圆角和加边框*/
#define DYViewBorderRadius(View,Radius,Width,Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

/** View圆角*/
#define DYViewRadius(View,Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

/** 多线程GCD*/
#define DYGlobalGCD(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define DYMainGCD(block) dispatch_async(dispatch_get_main_queue(),block)

/** 数据存储*/
#define kDYUserDefaults [NSUserDefaults standardUserDefaults]
#define kDYCacheDir [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define kDYDocumentDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define kDYTempDir NSTemporaryDirectory()

/** 获取temp*/
#define kDYPathTemp NSTemporaryDirectory()

/** 获取沙盒 Document*/
#define kDYPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

/** 获取沙盒 Cache*/
#define kDYPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

/** 非空block，把block和参数都写好，如果block不为空才执行*/
#define DYNotNilBlock(block, ...) if (block) { block(__VA_ARGS__); };

/** 获取相机权限状态（一般是直接用下面两个 拒绝或同意）*/
#define DYCameraStatus [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]
#define DYCameraDenied ((DYCameraStatus == AVAuthorizationStatusRestricted)||(DYCameraStatus == AVAuthorizationStatusDenied))
#define DYCameraAllowed (!DYCameraDenyed)

/** 定位权限*/
#define DYLocationStatus [CLLocationManager authorizationStatus];
#define DYLocationAllowed ([CLLocationManager locationServicesEnabled] && !((status == kCLAuthorizationStatusDenied) || (status == kCLAuthorizationStatusRestricted)))
#define DYLocationDenied (!DYLocationAllowed)

/** 消息推送权限*/
#define DYPushClose (([[UIDevice currentDevice].systemVersion floatValue]>=8.0f)?(UIUserNotificationTypeNone == [[UIApplication sharedApplication] currentUserNotificationSettings].types):(UIRemoteNotificationTypeNone == [[UIApplication sharedApplication] enabledRemoteNotificationTypes]))
#define DYPushOpen (!DYPushClose)

/** 直接跳到系统内本App的设置页面*/
#define DYGoToApplicationSettingPage [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

/** 获取一段时间间隔 */
#define kStartTime CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
#define kEndTimeNSLog(info) DYLog(@"%@ - Time: %f",info,CFAbsoluteTimeGetCurrent() - start)



#endif /* DYCommenMacros_h */
