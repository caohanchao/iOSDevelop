//
//  TSystemAuthorizationManager.m
//  timingapp
//
//  Created by caohanchao on 2021/2/23.
//  Copyright © 2021 huiian. All rights reserved.
//

#import "TSystemAuthorizationManager.h"
#import <Speech/Speech.h>
#import "TLocationManager.h"
@implementation TSystemAuthorizationManager

+ (instancetype)sharedInstance {
    static TSystemAuthorizationManager *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}

#pragma mark - Public Method
- (void)checkAndRequestAuthorition:(SystemAuthorizationType)type checkHandler:(void(^)(SystemAuthorizationStatus status,BOOL isAuthorized))checkHandler requestHandler:(void(^)(SystemAuthorizationStatus status,BOOL isAuthorized))requestHandler{
    switch (type) {
            //相册
        case SystemAuthorizationTypePhotoLibrary:
        {
            SystemAuthorizationStatus status = [self requestPhotoLibraryHander:requestHandler];
            if (status != SystemAuthorizationStatusNotDetermined) {
                checkHandler(status,status == SystemAuthorizationStatusAuthorized);
            }
            
        }
            break;
            //相机
        case SystemAuthorizationTypeCamera:
        {
            SystemAuthorizationStatus status = [self requestCameraHander:requestHandler];
            if (status != SystemAuthorizationStatusNotDetermined) {
                checkHandler(status,status == SystemAuthorizationStatusAuthorized);
            }
        }
            break;
            //定位
        case SystemAuthorizationTypeLocation:
        {
            SystemAuthorizationStatus status = [self requestLocationHander:requestHandler];
            if (status != SystemAuthorizationStatusNotDetermined) {
                checkHandler(status,status == SystemAuthorizationStatusAuthorized);
            }
        }
            break;
            //通知
        case SystemAuthorizationTypeNotification:
        {
            SystemAuthorizationStatus status = [self requestNotificationHander:requestHandler];
            if (status != SystemAuthorizationStatusNotDetermined) {
                checkHandler(status,status == SystemAuthorizationStatusAuthorized);
            }
        }
            break;
            //麦克风
        case SystemAuthorizationTypeAudio:
        {
            SystemAuthorizationStatus status = [self requestAudioHander:requestHandler];
            if (status != SystemAuthorizationStatusNotDetermined) {
                checkHandler(status,status == SystemAuthorizationStatusAuthorized);
            }
        }
            break;
            //语音识别
        case SystemAuthorizationTypeSpeechRecognizer:
        {
            SystemAuthorizationStatus status = [self requestSpeechRecognizerHander:requestHandler];
            if (status != SystemAuthorizationStatusNotDetermined) {
                checkHandler(status,status == SystemAuthorizationStatusAuthorized);
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)requestAuthorition:(SystemAuthorizationType)type completionHandler:(void(^)(SystemAuthorizationStatus status,BOOL isAuthorized))handler {
    switch (type) {
            //相册
        case SystemAuthorizationTypePhotoLibrary:
        {
            [self requestPhotoLibraryHander:handler];
        }
            break;
            //相机
        case SystemAuthorizationTypeCamera:
        {
            [self requestCameraHander:handler];
        }
            break;
            //定位
        case SystemAuthorizationTypeLocation:
        {
            [self requestLocationHander:handler];
        }
            break;
            //通知
        case SystemAuthorizationTypeNotification:
        {
            [self requestNotificationHander:handler];
        }
            break;
            //麦克风
        case SystemAuthorizationTypeAudio:
        {
            [self requestAudioHander:handler];
        }
            break;
            //语音识别
        case SystemAuthorizationTypeSpeechRecognizer:
        {
            [self requestSpeechRecognizerHander:handler];
        }
            break;
            
        default:
            break;
    }
}

- (void)checkAndRequestAuthorition:(SystemAuthorizationType)type
                 authorizedHandler:(void(^)(SystemAuthorizationStatus status,BOOL isAuthorized))authorizedHandler {
    [self checkAndRequestAuthorition:type checkHandler:^(SystemAuthorizationStatus status, BOOL isAuthorized) {
        if (isAuthorized) {
            authorizedHandler(status,isAuthorized);
        } else {
            [self showDeniedStatusAlertView:type];
        }
    } requestHandler:^(SystemAuthorizationStatus status, BOOL isAuthorized) {
        if (isAuthorized) {
            authorizedHandler(status,isAuthorized);
        }
    }];
}

- (void)checkAndRequestAuthorition:(SystemAuthorizationType)type
                 completionHandler:(void(^)(SystemAuthorizationStatus status,BOOL isAuthorized))handler {
    [self checkAndRequestAuthorition:type checkHandler:^(SystemAuthorizationStatus status, BOOL isAuthorized) {
        handler(status,isAuthorized);
    } requestHandler:^(SystemAuthorizationStatus status, BOOL isAuthorized) {
        if (isAuthorized) {
            handler(status,isAuthorized);
        }
    }];
}

- (SystemAuthorizationStatus)authoritionStatus:(SystemAuthorizationType)type{
    switch (type) {
            //相册
        case SystemAuthorizationTypePhotoLibrary:
        {
            return [self checkPhotoLibrary];
        }
            break;
            //相机
        case SystemAuthorizationTypeCamera:
        {
            return [self checkCamera];
        }
            break;
            //定位
        case SystemAuthorizationTypeLocation:
        {
            return [self checkLocation];
        }
            break;
            //通知
        case SystemAuthorizationTypeNotification:
        {
            return [self checkNotification];
        }
            break;
            //麦克风
        case SystemAuthorizationTypeAudio:
        {
            return [self checkAudio];
        }
            break;
            //语音识别
        case SystemAuthorizationTypeSpeechRecognizer:
        {
            return [self checkSpeechRecognizer];
        }
            break;
            
        default:
            //未定义
            return SystemAuthorizationStatusUnidentified;
            break;
    }
}

#pragma mark - Private Method
#pragma mark - 请求权限
//请求相册权限
- (SystemAuthorizationStatus)requestPhotoLibraryHander:(void(^)(SystemAuthorizationStatus stauts, BOOL isAuthorized))handler {
    SystemAuthorizationStatus photoLibraryStatus = [self checkPhotoLibrary];
    if (photoLibraryStatus == SystemAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusNotDetermined) {
                    handler(SystemAuthorizationStatusNotDetermined,NO);
                } else if (status == PHAuthorizationStatusAuthorized) {
                    handler(SystemAuthorizationStatusAuthorized,YES);
                } else {
                    handler(SystemAuthorizationStatusDenied,NO);
                }
            });
        }];
    }
    return photoLibraryStatus;
}

//请求相机权限
- (SystemAuthorizationStatus)requestCameraHander:(void(^)(SystemAuthorizationStatus stauts,BOOL isAuthorized))handler {
    SystemAuthorizationStatus cameraStatus = [self checkCamera];
    if (cameraStatus == SystemAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    handler(SystemAuthorizationStatusAuthorized,granted);
                } else {
                    handler(SystemAuthorizationStatusDenied,granted);
                }
            });
        }];
    }
    return cameraStatus;
}

//请求定位权限
- (SystemAuthorizationStatus)requestLocationHander:(void(^)(SystemAuthorizationStatus stauts,BOOL isAuthorized))handler {
    BOOL enable = [CLLocationManager locationServicesEnabled];
    SystemAuthorizationStatus status = [self checkLocation];
    if (!enable || status == SystemAuthorizationStatusNotDetermined) {
        [[TLocationManager sharedInstance] requestLocationRequest:^(BOOL granted, CLAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    handler(SystemAuthorizationStatusAuthorized,granted);
                } else {
                    handler(SystemAuthorizationStatusDenied,granted);
                }
            });
            
        }];
    }
    return status;
}

//请求通知权限
- (SystemAuthorizationStatus)requestNotificationHander:(void(^)(SystemAuthorizationStatus stauts,BOOL isAuthorized))handler {
    SystemAuthorizationStatus status = [self checkNotification];
    if (@available(iOS 10.0, *)) {
        if (status == SystemAuthorizationStatusNotDetermined) {
            UNAuthorizationOptions types = UNAuthorizationOptionBadge | UNAuthorizationOptionSound |UNAuthorizationOptionAlert;
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:types completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        handler(SystemAuthorizationStatusAuthorized,granted);
                    } else {
                        handler(SystemAuthorizationStatusDenied,granted);
                    }
                });
            }];
        }
    }else {
        //iOS10之前，系统对于申请推送权限没有具体的API，只有设置NotificationSettings时，会自动请求权限
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        SystemAuthorizationStatus status = [self checkNotification];
        handler(status,status == SystemAuthorizationStatusAuthorized);
    }

    return status;
}

//请求麦克风权限
- (SystemAuthorizationStatus)requestAudioHander:(void(^)(SystemAuthorizationStatus stauts,BOOL isAuthorized))handler {
    SystemAuthorizationStatus status = [self checkAudio];
    if (status == SystemAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    handler(SystemAuthorizationStatusAuthorized,granted);
                } else {
                    handler(SystemAuthorizationStatusDenied,granted);
                }
            });
        }];
    }
    return status;
}

//请求语音识别权限
- (SystemAuthorizationStatus)requestSpeechRecognizerHander:(void(^)(SystemAuthorizationStatus stauts,BOOL isAuthorized))handler {
    SystemAuthorizationStatus status = [self checkSpeechRecognizer];
    if (status == SystemAuthorizationStatusNotDetermined) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
                    handler(SystemAuthorizationStatusNotDetermined,NO);
                } else if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                    handler(SystemAuthorizationStatusAuthorized,YES);
                } else {
                    handler(SystemAuthorizationStatusDenied,NO);
                }
            });
        }];
    }
    return status;
}


#pragma mark - 权限状态
//检查相册权限状态
- (SystemAuthorizationStatus)checkPhotoLibrary {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        return SystemAuthorizationStatusNotDetermined;
    } else if (status == PHAuthorizationStatusAuthorized) {
        return SystemAuthorizationStatusAuthorized;
    } else {
        return SystemAuthorizationStatusDenied;
    }
}

//检查相机权限状态
- (SystemAuthorizationStatus)checkCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        return SystemAuthorizationStatusNotDetermined;
    } else if (status == AVAuthorizationStatusAuthorized) {
        return SystemAuthorizationStatusAuthorized;
    } else {
        return SystemAuthorizationStatusDenied;
    }
}

//检查定位权限状态
- (SystemAuthorizationStatus)checkLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        return SystemAuthorizationStatusNotDetermined;
    } else if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return SystemAuthorizationStatusAuthorized;
    } else {
        return SystemAuthorizationStatusDenied;
    }
}

//检查通知权限状态 (这里是个特例)
- (SystemAuthorizationStatus)checkNotification {
    if (@available(iOS 10.0, *)) {
        dispatch_semaphore_t singal = dispatch_semaphore_create(0);//创建信号量
        __block SystemAuthorizationStatus status;
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined){
                status = SystemAuthorizationStatusNotDetermined;
            }else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized){
                status = SystemAuthorizationStatusAuthorized;
            }else {
                status = SystemAuthorizationStatusDenied;
            };
            dispatch_semaphore_signal(singal);//赋值完成发送信号
        }];
        dispatch_semaphore_wait(singal, DISPATCH_TIME_FOREVER);//等待信号
        return status;
    }
    return ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) ? SystemAuthorizationStatusDenied : SystemAuthorizationStatusAuthorized;
}

//检查麦克风权限状态
- (SystemAuthorizationStatus)checkAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusNotDetermined) {
        return SystemAuthorizationStatusNotDetermined;
    } else if (status == AVAuthorizationStatusAuthorized) {
        return SystemAuthorizationStatusAuthorized;
    } else {
        return SystemAuthorizationStatusDenied;
    }
}

//检查语音识别权限状态
- (SystemAuthorizationStatus)checkSpeechRecognizer {
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
        return SystemAuthorizationStatusNotDetermined;
    } else if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
        return SystemAuthorizationStatusAuthorized;
    } else {
        return SystemAuthorizationStatusDenied;
    }
}

- (void)showDeniedStatusAlertView:(SystemAuthorizationType)type {
    NSString *message;
    switch (type) {
            //相册
            
        case SystemAuthorizationTypePhotoLibrary:
        {
            message = @"相册";
        }
            break;
            //相机
        case SystemAuthorizationTypeCamera:
        {
            message = @"相机";
        }
            break;
            //定位
        case SystemAuthorizationTypeLocation:
        {
            message = @"定位";
        }
            break;
            //通知
        case SystemAuthorizationTypeNotification:
        {
            message = @"通知";
        }
            break;
            //麦克风
        case SystemAuthorizationTypeAudio:
        {
            message = @"麦克风";
        }
            break;
            //语音识别
        case SystemAuthorizationTypeSpeechRecognizer:
        {
            message = @"语音识别";
        }
            break;
            
        default:
            break;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"此功能需要您开启%@权限，请前往设置中开启",message] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"下次开启" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self.getCurrentVC presentViewController:alertController animated:YES completion:nil];
}

/// 显示拒绝状态下的提示框（自定义弹窗：文案 + 我知道了）
/// @param type 权限类型
/// @param completionHandler 完成按钮的回调  isAuthorized的值都是no 拒绝授权
- (void)showDeniedStatusUnifiedAlertView:(SystemAuthorizationType)type
                       completionHandler:(void(^)(BOOL isAuthorized))completionHandler {
    NSString *message;
    switch (type) {
        case SystemAuthorizationTypePhotoLibrary:
            message = @"相册";
            break;
        case SystemAuthorizationTypeCamera:
            message = @"摄像头";
            break;
        case SystemAuthorizationTypeLocation:
            message = @"定位";
            break;
        case SystemAuthorizationTypeNotification:
            message = @"通知";
            break;
        case SystemAuthorizationTypeAudio:
            message = @"麦克风";
            break;
        case SystemAuthorizationTypeSpeechRecognizer:
            message = @"语音识别";
            break;
        default:
            break;
    }
    
    TUnifiedAlertView *alertView = [[TUnifiedAlertView alloc] initWithNoticeMsg:[NSString stringWithFormat:@"需要打开%@权限，请在手机设置中进行允许",message] btnText:@"我知道了" completion:^{
        completionHandler(NO);
    }];
    [alertView show];
}

@end
