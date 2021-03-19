//// TAudioPCMToMP3.h
// DenoiseKit
//
// 
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAudioPCMToMP3 : NSObject

/// PCM转MP3
/// @param pcmFilePath 原PCM文件
/// @param mp3FilePath mp3文件保存路径,内部不会自动创建文件夹
/// @param sampleRate AVSampleRate
/// @param completion 完成
- (void)audio_PCMtoMP3WithPCMFilePath:(NSString *)pcmFilePath
                          mp3FilePath:(NSString *)mp3FilePath
                           sampleRate:(float)sampleRate
                           completion:(void (^)(NSString *mp3FilePath, BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
