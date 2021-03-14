//// TDenoiseTool.m
// timingapp
//
// Copyright © 2021 huiian. All rights reserved.
//


#import "TDenoiseTool.h"

#define DR_WAV_IMPLEMENTATION

#include "dr_wav.h"
#include "timing.h"
#include "noise_suppression.h"

#ifndef nullptr
#define nullptr 0
#endif

#ifndef MIN
#define MIN(A, B)        ((A) < (B) ? (A) : (B))
#endif

@interface TDenoiseTool ()

/** 降噪失败的回调 */
@property (nonatomic, copy) DenoiseErrorCallback denoiseErrorCallback;

@end

@implementation TDenoiseTool

- (instancetype)init {
    self = [super init];
    if (self) {
        self.format = TDenoiseFormatPCM;
        self.level = TDenoiseLevelHigh;
        self.channels = 2;
        self.bitsPerSample = 16;
    }
    return self;
}

#pragma mark — 降噪
- (void)denoiseInpath:(NSString *)inpath outpath:(NSString *)outpath denoiseErrorCallback:(DenoiseErrorCallback)denoiseErrorCallback {
    
    self.denoiseErrorCallback = denoiseErrorCallback;
    
    /// 先清除噪音文件
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:outpath isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:outpath error:&error];
    }
    
    const char *in_file  = [inpath  UTF8String];
    const char *out_file = [outpath UTF8String];
    
    char in_f[1024];
    //把从src地址开始且含有'\0'结束符的字符串复制到以dest开始的地址空间，返回值的类型为char*
    strcpy(in_f,in_file);
    
    char out_f[1024];
    strcpy(out_f,out_file);
    
    [self noise_suppression:in_f and:out_f];
    
}

- (void)noise_suppression:(char *)in_file and:(char *)out_file {
    //音频采样率
    uint32_t sampleRate = 0;
    //总音频采样数
    uint64_t inSampleCount = 0;
    
    int16_t *inBuffer = [self wavRead_int16:in_file :&sampleRate :&inSampleCount];
    
    //如果加载成功
    if (inBuffer != nullptr) {
        double startTime = now();
        [self nsProcess:inBuffer :sampleRate :(int)inSampleCount :self.level];
        double time_interval = calcElapsed(startTime, now());
        printf("time interval: %d ms\n ", (int) (time_interval * 1000));
        [self wavWrite_int16:out_file :inBuffer :sampleRate :inSampleCount];
        free(inBuffer);
    }
}

//写wav文件
- (void)wavWrite_int16:(char *)filename :(int16_t *)buffer :(size_t)sampleRate :(size_t)totalSampleCount {
    drwav_data_format format = {};
    format.container = drwav_container_riff;     // <-- drwav_container_riff = normal WAV files, drwav_container_w64 = Sony Wave64.
    format.format = DR_WAVE_FORMAT_PCM;          // <-- Any of the DR_WAVE_FORMAT_* codes.
    format.channels = self.channels;
    format.sampleRate = (drwav_uint32)sampleRate;
    format.bitsPerSample = self.bitsPerSample;
    drwav *pWav = drwav_open_file_write(filename, &format);
    if (pWav) {
        drwav_uint64 samplesWritten = drwav_write(pWav, totalSampleCount, buffer);
        drwav_uninit(pWav);
        if (samplesWritten != totalSampleCount) {
            fprintf(stderr, "ERROR\n");
            [self error];
            exit(1);
        }
    }
}

//读取wav文件
- (int16_t *)wavRead_int16:(char *)filename :(uint32_t *)sampleRate :(uint64_t *)totalSampleCount {
    unsigned int channels;
    int16_t *buffer = drwav_open_and_read_file_s16(filename, &channels, sampleRate, totalSampleCount);
    if (buffer == nullptr) {
        printf("ERROR.");
        [self error];
    }
    return buffer;
}

- (int)nsProcess:(int16_t *)buffer :(uint32_t)sampleRate :(int)samplesCount :(TDenoiseLevel)level {
    if (buffer == nullptr) return -1;
    if (samplesCount == 0) return -1;
    size_t samples = MIN(160, sampleRate / 100);
    if (samples == 0) return -1;
    uint32_t num_bands = 1;
    int16_t *input = buffer;
    size_t nTotal = (samplesCount / samples);
    NsHandle *nsHandle = WebRtcNs_Create();
    int status = WebRtcNs_Init(nsHandle, sampleRate);
    if (status != 0) {
        printf("WebRtcNs_Init fail\n");
        [self error];
        return -1;
    }
    status = WebRtcNs_set_policy(nsHandle, (int)level);
    if (status != 0) {
        printf("WebRtcNs_set_policy fail\n");
        [self error];
        return -1;
    }
    for (int i = 0; i < nTotal; i++) {
        int16_t *nsIn[1] = {input};   //ns input[band][data]
        int16_t *nsOut[1] = {input};  //ns output[band][data]
        WebRtcNs_Analyze(nsHandle, nsIn[0]);
        WebRtcNs_Process(nsHandle, (const int16_t *const *) nsIn, num_bands, nsOut);
        input += samples;
    }
    WebRtcNs_Free(nsHandle);
    
    return 1;
}

- (void)error {
    if (self.denoiseErrorCallback) {
        self.denoiseErrorCallback();
    }
}

@end
