

# 1.AVAudioSession

简要说说AVAudioSession，AVAudioSession是苹果用来管理App对音频硬件（I / O）的资源使用；比如说：

- 设置APP与其他APP是否混音，或者中断、降低其他App声音
- 手机静音下，APP是否可以播放声音
- 指定音频输入或者输出设备
- 是否支持APP录制，是否可以边录制边播放
- 声音中断的优先级（电话接入中断APP音频处理）

在APP的运行过程中Audio Session的配置影响所有的音频活动。你可以查询Audio Session来发现设备的硬件特性---例如声道数（channel count）、采样率（sample rate）、和音频输入的可用性（availability of audio unit）

**激活AVAudioSession**

```objective-c
//设置为激活或者失活。激活音频会话是一个同步（阻塞）操作
- (BOOL)setActive:(BOOL)active 
        error:(NSError * _Nullable *)outError;
//调用该方法 通知中断的应用程序中断已经结束，它可以恢复播放，仅在会话停用时有效
// active：NO
// options：AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
- (BOOL)setActive:(BOOL)active withOptions:(AVAudioSessionSetActiveOptions)options error:(NSError **)outError;
```

**设置首选音频硬件值**

```objective-c
//首选硬件采样率
- (BOOL)setPreferredSampleRate:(double)sampleRate error:(NSError **)outError
//首选的硬件IO缓冲区持续时间(以秒为单位)
- (BOOL)setPreferredIOBufferDuration:(NSTimeInterval)duration error:(NSError **)outError
```



# 2.AvAudioSession Category

AvAudioSession中可以设置Category和Option，每一种Category都对应是否支持以下几种能力：

- ***Interrupts non-mixable apps audio* ：  是否打断不支持混音播放的APP**
- ***Silenced by the Silent switch*：是否会被手机静音键开关影响**
- ***Supports audio input / output*：是否支持音频录制、播放**

下面用图表来直观感受下category的枚举值：

|             **Category**              | **支持播放** | **支持录音** | **支持混音** | **会被静音键或锁屏键静音** |
| :-----------------------------------: | :----------: | :----------: | :----------: | :------------------------: |
|     AVAudioSessionCategoryAmbient     |      √       |      X       |      √       |             √              |
|   AVAudioSessionCategorySoloAmbient   |      √       |      X       |      X       |             √              |
|    AVAudioSessionCategoryPlayback     |      √       |      X       | 可选，默认 X |             X              |
|     AVAudioSessionCategoryRecord      |      X       |      √       |      √       |             X              |
|  AVAudioSessionCategoryPlayAndRecord  |      √       |      √       | 可选，默认 X |             X              |
| AVAudioSessionCategoryAudioProcessing |      X       |      X       |      X       |             X              |
|   AVAudioSessionCategoryMultiRoute    |      √       |      X       |      √       |             X              |

- ***AVAudioSessionCategoryAmbient***  只支持音频播放。这个分类下，音频播放时会被静音键和锁屏键静音，可以与其他APP混音。
- ***AVAudioSessionCategorySoloAmbient*** 系统默认，只支持音频播放，音频会被静音键和锁屏键静音，会打断其他APP音频播放。
- ***AVAudioSessionCategoryPlayback*** 只支持音频播放，音频不会被静音键和锁屏键静音，适用于音频是主要功能的APP，锁屏后依然可以播放。（后台播放需要开启音频相关的后台支持[UIBackgroundModes](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html#//apple_ref/doc/uid/TP40009252-SW22)）
- ***AVAudioSessionCategoryRecord*** 只支持音频录制，不支持播放。
- ***AVAudioSessionCategoryPlayAndRecord*** 支持音频录制和播放，声音在没有外设的情况下，默认为听筒播放，常用到语音聊天应用；
- ***AVAudioSessionCategoryAudioProcessing*** 使用硬件编解码器或信号处理器而不播放或录制音频时使用此类别
- ***AVAudioSessionCategoryMultiRoute* **定制可用的音频附件和内置音频硬件的使用定制（注意：使用此分类需要更详细的知识和交互，并非所有输出类型和输出组合都适合多路由）

**关于Audio Route的选择**

当iPhone接入多个外部设备时，AudioSeesion将遵循***last-in wins***原则（后入为主），即声音将被导向到最后接入的设备。在没有接入任何设备时，一般情况下声音会默认从扬声器发出，但有一个例外：在使用**AVAudioSessionCategoryPlayAndRecord**这种category下，听筒成为默认的输出设备。如果需要改变输出的设备，有以下几种方式：[区别参照苹果文档](https://developer.apple.com/library/archive/qa/qa1754/_index.html)

- 设置category 方法中`options` 为*AVAudioSessionCategoryOptionDefaultToSpeaker*
- 调用覆盖音频输出方法 `- (BOOL)overrideOutputAudioPort:(AVAudioSessionPortOverride)portOverride error:(NSError **)outError`  设置 `portOverride` 为 *AVAudioSessionPortOverrideSpeaker*

**设置category**（苹果文档中提醒到要考虑设置失败）

```objective-c
/* set session category */
- (BOOL)setCategory:(AVAudioSessionCategory)category error:(NSError **)outError API_AVAILABLE(ios(3.0), watchos(2.0), tvos(9.0)) API_UNAVAILABLE(macos);
/* set session category with options */
- (BOOL)setCategory:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError **)outError API_AVAILABLE(ios(6.0), watchos(2.0), tvos(9.0)) API_UNAVAILABLE(macos);
/* set session category and mode with options */
- (BOOL)setCategory:(AVAudioSessionCategory)category mode:(AVAudioSessionMode)mode options:(AVAudioSessionCategoryOptions)options error:(NSError **)outError API_AVAILABLE(ios(10.0), watchos(3.0), tvos(10.0)) API_UNAVAILABLE(macos);
/* set session category, mode, routing sharing policy, and options */
- (BOOL)setCategory:(AVAudioSessionCategory)category mode:(AVAudioSessionMode)mode routeSharingPolicy:(AVAudioSessionRouteSharingPolicy)policy options:(AVAudioSessionCategoryOptions)options error:(NSError **)outError API_AVAILABLE(ios(11.0), tvos(11.0), watchos(5.0)) API_UNAVAILABLE(macos);
```

# 3.AVAudioSession Mode && CategoryOptions && More

## 3.1.AVAudioSession Mode 

**音频会话模式** （用来定制category的行为）

|               模式               |                           Category                           |              场景              |
| :------------------------------: | :----------------------------------------------------------: | :----------------------------: |
|    AVAudioSessionModeDefault     |                             All                              |              默认              |
|   AVAudioSessionModeVoiceChat    |             AVAudioSessionCategoryPlayAndRecord              |       VoIP （语音通话）        |
|    AVAudioSessionModeGameChat    |             AVAudioSessionCategoryPlayAndRecord              |            游戏模式            |
| AVAudioSessionModeVideoRecording | AVAudioSessionCategoryRecord、AVAudioSessionCategoryPlayAndRecord | 适用于使用摄像头采集视频的应用 |
|  AVAudioSessionModeMeasurement   | AVAudioSessionCategoryRecord、AVAudioSessionCategoryPlayAndRecord |           最小化系统           |
| AVAudioSessionModeMoviePlayback  |                AVAudioSessionCategoryPlayback                |            视频播放            |
|   AVAudioSessionModeVideoChat    | AVAudioSessionCategoryPlayback、AVAudioSessionCategoryPlayAndRecord |            视频通话            |
|  AVAudioSessionModeSpokenAudio   | AVAudioSessionCategorySoloAmbient、AVAudioSessionCategoryPlayback、AVAudioSessionCategoryPlayAndRecord、AVAudioSessionCategoryMultiRoute |            有声读物            |
|  AVAudioSessionModeVoicePrompt   |                              -                               |            语音提示            |

- ***AVAudioSessionModeDefault*** 默认模式 兼容所有category
- ***AVAudioSessionModeVoiceChat*** 适用于语音聊天VoIP
- ***AVAudioSessionModeGameChat*** 适用于游戏模式，不需要主动设置（若不想用GKVoiceChat但希望达到类似功能，可以使用AVAudioSessionModeVoiceChat）
- ***AVAudioSessionModeVideoRecording*** 适用于使用摄像头采集视频的应用
- ***AVAudioSessionModeMeasurement*** 适用于希望将系统提供的用于输入和/或输出音频信号的信号处理的影响最小化的应用
- ***AVAudioSessionModeMoviePlayback*** 适用于AVAudioSessionCategoryPlayback下的视频播放
- ***AVAudioSessionModeVideoChat*** 适用于视频聊天 系统会自动配置AVAudioSessionCategoryOptionAllowBluetooth和AVAudioSessionCategoryOptionDefaultToSpeaker
- ***AVAudioSessionModeSpokenAudio*** 当其他应用程序播放短暂的语音提示时，希望自己的音频暂停而不是回避（声音变小）时使用
- ***AVAudioSessionModeVoicePrompt*** 当程序内音频为简单的语音提示时使用。适用于导航中的播报

## 3.2.AVAudioSession CategoryOptions

**选项组合**

|                            Option                            |             功能说明             |                         支持Category                         |
| :----------------------------------------------------------: | :------------------------------: | :----------------------------------------------------------: |
|          AVAudioSessionCategoryOptionMixWithOthers           |             支持混音             | AVAudioSessionCategoryPlayAndRecord AVAudioSessionCategoryPlayback AVAudioSessionCategoryMultiRoute |
|            AVAudioSessionCategoryOptionDuckOthers            |      压低其他应用的音频音量      | AVAudioSessionCategoryPlayAndRecord AVAudioSessionCategoryPlayback AVAudioSessionCategoryMultiRoute |
|          AVAudioSessionCategoryOptionAllowBluetooth          |         支持蓝牙音频输入         | AVAudioSessionCategoryRecord AVAudioSessionCategoryPlayAndRecord |
|         AVAudioSessionCategoryOptionDefaultToSpeaker         |       设置默认输出到扬声器       |             AVAudioSessionCategoryPlayAndRecord              |
| AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers | 音频播放过程中，支持中断其他应用 | AVAudioSessionCategoryPlayAndRecord AVAudioSessionCategoryPlayback AVAudioSessionCategoryMultiRoute |
|        AVAudioSessionCategoryOptionAllowBluetoothA2DP        |          支持立体声蓝牙          | AVAudioSessionCategoryAmbient AVAudioSessionCategorySoloAmbient AVAudioSessionCategoryPlayback AVAudioSessionCategoryPlayAndRecord |
|           AVAudioSessionCategoryOptionAllowAirPlay           |         支持远程AirPlay          |             AVAudioSessionCategoryPlayAndRecord              |

- ***AVAudioSessionCategoryOptionMixWithOthers***：*AVAudioSessionCategoryPlayAndRecord* 、*AVAudioSessionCategoryMultiRoute*默认不设置，若设置后，当程序同时启动音频输入输出时，允许程序后台运行；*AVAudioSessionCategoryPlayback*默认不设置，若设置后，无论是铃声还是在静音模式下，仍然能够播放
- ***AVAudioSessionCategoryOptionDuckOthers***：当前session处于active时，其他音频就是回避状态(压低声音) *AVAudioSessionCategoryPlayAndRecord*、*AVAudioSessionCategoryPlayback*、*AVAudioSessionCategoryMultiRoute* 默认不混音，不回避
- ***AVAudioSessionCategoryOptionAllowBluetooth***：允许将蓝牙作为可用途径。支持*AVAudioSessionCategoryPlayAndRecord*、*AVAudioSessionCategoryRecord*
- ***AVAudioSessionCategoryOptionDefaultToSpeaker***：允许改变音频session默认选择内置扬声器（免提）；仅支持*AVAudioSessionCategoryPlayAndRecord*
- ***AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers***：如果设置了这个选项，系统就会将你的音频与其他音频会话混合，但是会中断(并停止)使用*AVAudioSessionModeSpokenAudio*模式的音频会话；只要会话处于活动状态，它就会暂停来自其他应用程序的音频。音频会话失活后，系统恢复被中断的应用程序的音频。
- ***AVAudioSessionCategoryOptionAllowBluetoothA2DP***：A2DP是一种立体声、仅输出的配置文件用于更高带宽的音频。如果使用AVAudioSessionCategoryAmbient、AVAudioSessionCategorySoloAmbient或AVAudioSessionCategoryPlayback类别，系统会自动路由到A2DP端口；从iOS 10.0开始，使用AVAudioSessionCategoryPlayAndRecord类别的应用程序也可以将输出路由到配对的蓝牙A2DP设备。要启用此行为，请在设置音频会话的类别时传递此类别选项。
- ***AVAudioSessionCategoryOptionAllowAirPlay***：设置此选项可使音频会话将音频输出路由到AirPlay设备。设置为AVAudioSessionCategoryPlayAndRecord，则只能显式地设置此选项。对于大多数其他音频会话类别，系统隐式地设置此选项。

**注意**：如果应用中使用到MPNowPlayingInfoCenter，最好避免设置*AVAudioSessionCategoryOptionMixWithOthers*；因为一旦设置了这个值之后，那么MPNowPlayingInfoCenter就不能正常显示信息；

## 3.3.AVAudioSession RouteSharingPolicy 

**路由策略**

- ***AVAudioSessionRouteSharingPolicyDefault*** 遵循正常的规则路由音频输出
- ***AVAudioSessionRouteSharingPolicyLongFormAudio*** 将输出路由到共享的长格式音频输出
- ***~~AVAudioSessionRouteSharingPolicyLongForm~~*** 已废弃
- ***AVAudioSessionRouteSharingPolicyIndependent*** 应用程序不应试图直接设置此值。在iOS上，当路由选择器UI用于将视频定向到无线路由时，系统将设置此值。
- ***AVAudioSessionRouteSharingPolicyLongFormVideo*** 将输出路由到共享的长格式视频输出（使用此策略的应用程序在其Info.plist中设置AVInitialRouteSharingPolicy键）

# 4.AVAudioSession Notification

## 4.1.系统中断响应通知 AVAudioSessionInterruptionNotification

当App内音频被中断，系统会将AudioSession置为失活状态，音频也会因此立即停止。当一个别的App的AudioSession被激活并且它的类别未设置与系统类别或你应用程序类别混合时，中断就会发生。你的应用程序在收到中断通知后应该保存当时的状态，以及更新用户界面等相关操作。通过注册`AVAudioSessionInterruptionNotification`通知，可以处理中断的开始和结束。

```objective-c
/* keys for AVAudioSessionInterruptionNotification */
/* Value is an NSNumber representing an AVAudioSessionInterruptionType */
AVAudioSessionInterruptionTypeKey
typedef NS_ENUM(NSUInteger, AVAudioSessionInterruptionType)
{
	AVAudioSessionInterruptionTypeBegan = 1,  /* the system has interrupted your audio session */
	AVAudioSessionInterruptionTypeEnded = 0,  /* the interruption has ended */
};
  
/* Only present for end interruption events.  Value is of type AVAudioSessionInterruptionOptions.*/
AVAudioSessionInterruptionOptionKey
typedef NS_OPTIONS(NSUInteger, AVAudioSessionInterruptionOptions)
{
	AVAudioSessionInterruptionOptionShouldResume = 1
};
```

适用场景：电话接入、闹钟、定时任务、其他App音频激活；

**提示：这里的通知的中断开始和中断接触不一定都会出现（苹果文档中有提到）**

## 4.2.音频线路变更通知 AVAudioSessionRouteChangeNotification

当用户连接或者断开音频输入，输出设备时（插拔耳机、或者蓝牙耳机的断开、连接），音频线路发生变更，通过注册`AVAudioSessionRouteChangeNotification`通知，可以在音频线路发生变更时做出相应处理。

```objective-c
/* keys for AVAudioSessionRouteChangeNotification */
/* value is an NSNumber representing an AVAudioSessionRouteChangeReason */
AVAudioSessionRouteChangeReasonKey
typedef NS_ENUM(NSUInteger, AVAudioSessionRouteChangeReason)
{
	AVAudioSessionRouteChangeReasonUnknown = 0,
	AVAudioSessionRouteChangeReasonNewDeviceAvailable = 1, 	//设备可用（耳机插好）
	AVAudioSessionRouteChangeReasonOldDeviceUnavailable = 2, //设备不可用（耳机被拔下）
	AVAudioSessionRouteChangeReasonCategoryChange = 3, //  设置的分类被改变
	AVAudioSessionRouteChangeReasonOverride = 4,			//  路由被覆盖
	AVAudioSessionRouteChangeReasonWakeFromSleep = 6,  // 设备被激活
	AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory = 7, //当前类别没有路由时返回
	AVAudioSessionRouteChangeReasonRouteConfigurationChange = 8 // added in iOS 7
};
```



## 4.3.其他应用音频状态提示通知 AVAudioSessionSilenceSecondaryAudioHintNotification

当来自其他应用的主音频启动，或者停止时，通过注册`AVAudioSessionSilenceSecondaryAudioHintNotification`通知，前台应用可以作为启动或者禁用次要音频的提示；

```objective-c
/* keys for AVAudioSessionSilenceSecondaryAudioHintNotification */
/* value is an NSNumber representing an AVAudioSessionSilenceSecondaryAudioHintType */
AVAudioSessionSilenceSecondaryAudioHintTypeKey 
typedef NS_ENUM(NSUInteger, AVAudioSessionSilenceSecondaryAudioHintType)
{
	AVAudioSessionSilenceSecondaryAudioHintTypeBegin = 1,  /* the system is indicating that another application's primary audio has started */
	AVAudioSessionSilenceSecondaryAudioHintTypeEnd = 0,    /* the system is indicating that another application's primary audio has stopped */
};
```



# 5.AVAudioSession 的相关问题

针对我们应用中声音可能出现问题大致有：不需要混音的地方出现了混音，录制后播放从听筒播出，中断后无法恢复声音，耳机无法使用等等；声音问题归根结底就是AudioSession设置的问题；虽然设置的方法比较简单，但是一旦出现问题，又很难排查， 在众多场景中如何调配确实是一个需要考虑的问题；

1. 场景切换后，是否需要重新设置category？
2. 如何选择Option去适应用户的选择？
3. 当前的录制状态是否会引起播放的问题？

可能还有很多的问题在等着我们去思考；

# 6.AVAudioSession 总结

针对可以播放和录制的App来说，这一类型的APP使用AVAudioSessionCategoryRecord，AVAudioSessionCategoryPlayAndRecord，AVAudioSessionCategoryPlayback类别；这类APP的音频准则建议如下：

- 当应用程序进入前台时，请等待用户按下“播放”或“录制”按钮，然后再激活音频会话。
- 当应用程序处于前台时，除非中断，否则请保持音频会话处于活动状态。
- 如果应用程序在过渡到后台时没有活跃的播放或录制音频，请停用其音频会话。这样可以防止其音频会话被另一个不可混合的应用程序中断，或者在应用程序被系统挂起时响应中断其音频会话。
- 在被中断后更新用户界面的播放或录制到暂停。请勿停用音频会话。
- 观察`AVAudioSessionInterruptionNotification`有关音频会话中断的通知类型。中断结束后，请勿再次开始播放或录制音频，除非该应用在中断之前就已经开始了。
- 如果路由更改是由拔出事件引起的，则暂停播放或录制，但请保持音频会话处于活动状态。
- 假设应用程序的音频会话从挂起状态转换为前台状态时处于失活状态。当用户按下“播放”或“录制”按钮时，重新激活音频会话。
- 确保`UIBackgroundModes`已设置音频标志。
- 注册远程控制事件（请参阅参考资料`MPRemoteCommandCenter`），并为您的媒体提供适当的“正在播放”信息（请参阅参考资料`MPNowPlayingInfoCenter`）。
- 使用一个`MPVolumeView`对象显示系统音量滑块和路线选择器。
- 使用后台任务而不是静默播放流，以防止应用程序被暂停。
- 要求用户许可使用该`requestRecordPermission:`方法记录输入。不要依靠操作系统来提示用户。
- 对于录制应用程序，请使用`AVAudioSessionCategoryPlayAndRecord`类别而不是`AVAudioSessionCategoryRecord`类别。“仅记录”类别几乎使所有系统输出静音，并且通常对于大多数应用程序而言过于严格。

更多其他类型的APP[可以参照苹果指南](https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/AudioGuidelinesByAppType/AudioGuidelinesByAppType.html#//apple_ref/doc/uid/TP40007875-CH11-SW1)

# 7.声音场景的使用

关于项目中恢复其他应用音频播放的方法，通过尝试了很多方法，但是都不是很理想，而且尝试deactive还会遇到很多问题，现总结下项目中如何解决的办法：

> 场景1:如果A应用中播放音频，进入B应用中播放视频时，A暂停播放；B结束播放后，A恢复音频播放；
>
> ```objective-c
> //开始
> //1 先激活音频
> [[AudioSession sharedInstance] setActive:YES error:&error];
> //2 设置支持可混合音频
> [[AudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
> //结束 暂停所有I/0
> //3 还原默认设置
> [[AudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&error];
> //4 失活当前音频，唤起其他App播放
> [[AudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
> ```
>
> 场景2:如果A应用中播放音频，进入B应用中录制时，A暂停播放；B结束录制后，A恢复音频播放；
>
> ```objective-c
> //开始
> //1 先激活音频
> [[AudioSession sharedInstance] setActive:YES error:&error];
> //2 设置支持可混合音频
> [[AudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionAllowBluetooth error:&error];
> //结束 暂停所有I/0
> //3 还原默认设置
> [[AudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&error];
> //4 失活当前音频，唤起其他App播放
> [[AudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
> ```
>
> 场景3. 播放应用内的视频时暂停外部音乐；
>
> ```objective-c
> [[AudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:&error];
> [[AudioSession sharedInstance] setActive:YES error:&error];
> [[AudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
> ```
>
> 场景4. 混音播放外部音频，同时插播一条应用内的语音（播放语音时，外部音频降低音量，播放语音完毕后，外部音频恢复音量）；
>
> ```objective-c
> // 播放开始
> [[AudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error];
> 
> // 播放结束
> [[AudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
> ```





# **参考文档**

1. [Audio Session Programming Guide](https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Introduction/Introduction.html)

2. [AVAudioSession Class Reference](https://developer.apple.com/documentation/avfoundation/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionallowairplay?language=objc)

3. [人机交互准则](https://developer.apple.com/design/human-interface-guidelines/ios/user-interaction/audio/)

   

