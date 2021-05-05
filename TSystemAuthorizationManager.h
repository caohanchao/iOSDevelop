//
//  TSystemAuthorizationManager.h
//  timingapp
//
//  Created by caohanchao on 2021/2/23.
//  Copyright © 2021 huiian. All rights reserved.
//

/**
  * @功能描述：系统权限管理类
  * @创建时间：2021/2/23
  * @创建人：曹汉超
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//App需要用到的权限枚举
typedef NS_ENUM(NSUInteger, SystemAuthorizationType) {
    SystemAuthorizationTypePhotoLibrary,      //相册
    SystemAuthorizationTypeCamera,            //相机
    SystemAuthorizationTypeLocation,          //定位
    SystemAuthorizationTypeNotification,      //通知
    SystemAuthorizationTypeAudio,             //麦克风
    SystemAuthorizationTypeSpeechRecognizer,  //语音识别
};

//当前权限状态枚举
typedef NS_ENUM(NSUInteger, SystemAuthorizationStatus) {
    SystemAuthorizationStatusNotDetermined,      //未选择
    SystemAuthorizationStatusAuthorized,      //授权
    SystemAuthorizationStatusDenied,        //拒绝授权
    SystemAuthorizationStatusUnidentified,  //未识别
};

#define SystemAuthorizationShared [TSystemAuthorizationManager sharedInstance]

@interface TSystemAuthorizationManager : NSObject

AS_SINGLETON(TSystemAuthorizationManager)

/// 查看权限&请求权限 (在设备未授权过的状态下才会请求权限，如果请求过权限，无论授权或者拒绝授权，后                                                                                   面都不会再去请求该权限了)
/// @param type 权限类型
/// @param checkHandler 检查权限 （未授权过的时候，这个回调无效）
/// @param requestHandler 请求权限 （授权或者拒绝授权后，这个回调无效）
- (void)checkAndRequestAuthorition:(SystemAuthorizationType)type
                      checkHandler:(void(^)(SystemAuthorizationStatus status,BOOL isAuthorized))checkHandler
                    requestHandler:(void(^)(SystemAuthorizationStatus status,BOOL isAuthorized))requestHandler;


/// 查看权限&请求权限 
/// @param type 权限类型
/// @param completionHandler  完成的回调 （查询时，授权和拒绝授权会走此回调； 未授权会请求授权权限；申请授权时，授权会走此回调，拒绝授权不会走此回调；）
- (void)checkAndRequestAuthorition:(SystemAuthorizationType)type
                 completionHandler:(void(^)(SystemAuthorizationStatus status,BOOL isAuthorized))handler;


/// 查看权限&请求权限 （只需要关注授权成功的操作,查询到授权失败会自动系统提示框）
/// @param type 权限类型
/// @param authorizedHandler  权限授权的回调 （拒绝会自动弹出提示框；未授权会请求授权权限；这里的回调只有成功授权才会走）
- (void)checkAndRequestAuthorition:(SystemAuthorizationType)type
                 authorizedHandler:(void(^)(SystemAuthorizationStatus status,BOOL isAuthorized))authorizedHandler;

/// 请求权限
/// @param type 权限类型
/// @param handler 回调
- (void)requestAuthorition:(SystemAuthorizationType)type
         completionHandler:(void(^)(SystemAuthorizationStatus status,BOOL isAuthorized))handler;

/// 查询权限状态
/// @param type 权限类型
- (SystemAuthorizationStatus)authoritionStatus:(SystemAuthorizationType)type;

/// 显示拒绝状态下的提示框（系统弹窗：下次开启 / 立即开启）
/// @param type 权限类型
- (void)showDeniedStatusAlertView:(SystemAuthorizationType)type;


/// 显示拒绝状态下的提示框（自定义弹窗：文案 + 我知道了）
/// @param type 权限类型
/// @param completionHandler 完成按钮的回调  isAuthorized的值都是no 拒绝授权
- (void)showDeniedStatusUnifiedAlertView:(SystemAuthorizationType)type
                        completionHandler:(void(^)(BOOL isAuthorized))completionHandler;

@end

NS_ASSUME_NONNULL_END
