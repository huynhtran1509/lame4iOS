//
//  XTMP3EncoderTool.h
//  lame4iOS
//
//  Created by 晓童 韩 on 16/1/25.
//  Copyright © 2016年 晓童 韩. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ConvertCompletionBlock)(BOOL);

@interface XTMP3EncoderTool : NSObject

/**
 *  将wav文件转换为mp3文件
 *
 *  @param wavPath
 *  @param mp3Path
 *  @param compblock
 */
+ (void)convertFromWav:(NSString *)wavPath toMp3:(NSString *)mp3Path block:(ConvertCompletionBlock)compblock;

@end
