//// TDenoiseTool.h
// timingapp
//
// Copyright © 2021 huiian. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 源文件格式
typedef NS_ENUM(NSUInteger, TDenoiseFormat) {
    TDenoiseFormatPCM,  /// DR_WAVE_FORMAT_PCM
    TDenoiseFormatADPCM,  /// DR_WAVE_FORMAT_ADPCM
    TDenoiseFormatIEEE_FLOAT,  /// DR_WAVE_FORMAT_IEEE_FLOAT
    TDenoiseFormatALAW,  /// DR_WAVE_FORMAT_ALAW
    TDenoiseFormatMULAW,  /// DR_WAVE_FORMAT_MULAW
    TDenoiseFormatDVI_ADPCM,  /// DR_WAVE_FORMAT_DVI_ADPCM
    TDenoiseFormatEXTENSIBLE   /// DR_WAVE_FORMAT_EXTENSIBLE
};

/// 降级等级
typedef NS_ENUM(NSUInteger, TDenoiseLevel) {
    TDenoiseLevelLow,
    TDenoiseLevelModerate,
    TDenoiseLevelHigh,
    TDenoiseLevelVeryHigh
};

/// 降噪失败的回调
typedef void(^DenoiseErrorCallback)(void);

@interface TDenoiseTool : NSObject


/** 格式(默认:TDenoiseFormatPCM) */
@property (nonatomic, assign) TDenoiseFormat format;
/** 等级(默认:TDenoiseLevelHigh) */
@property (nonatomic, assign) TDenoiseLevel level;
/** 声道数量(默认:2) */
@property (nonatomic, assign) UInt32 channels;
/** 采样率(默认:16) */
@property (nonatomic, assign) UInt32 bitsPerSample;

#pragma mark — 降噪
- (void)denoiseInpath:(NSString *)inpath outpath:(NSString *)outpath denoiseErrorCallback:(DenoiseErrorCallback)denoiseErrorCallback;

@end

NS_ASSUME_NONNULL_END
