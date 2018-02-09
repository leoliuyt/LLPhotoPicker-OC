//
//  LLUtil.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLUtil : NSObject
+ (NSString *)thumbSuffix;
+ (NSString *)bigSuffix;
+ (NSString *)createUDID;

+ (BOOL)checkUseCamera;
+ (BOOL)checkUseRecord;

+ (BOOL)isChinaMobile:(NSString *)aPhoneNum;

+ (char)pinyinFirstLetter:(unsigned short)aHanzi;

+ (void)makeCall:(NSString *)aPhoneNumber;

+ (long)timeIntervalWith:(NSString *)timeString;

+ (void)gotoSafari:(NSString *)url;
//视频相关
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
+ (CGFloat) getFileSize:(NSString *)path;
+ (CGFloat) getVideoLength:(NSURL *)URL;

//播放系统提示音
+ (void)playSystemTipAudioIsBegin:(BOOL)isBegin;

NSString* CheckString(NSString *aString);


+ (NSString*)commonStringForSecond:(NSInteger)aSecond;

//文件夹不存在则创建
+(NSString *)createDirectoriesIfNeededAtPath:(NSString *)aPath;
+(NSURL *)createDirectoriesIfNeededAtURL:(NSURL *)aURL;
+ (void)openSystemSetting;


/**
 同步操作，超时活着block执行完成后，再执行后续操作

 @param timeout 超时时间 单位s
 @param executeBlock 执行的操作
 */
+ (void)synExecuteTimeOut:(NSTimeInterval)timeout executeBlock:(void(^)(void))executeBlock;

@end
