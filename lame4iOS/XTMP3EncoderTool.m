//
//  XTMP3EncoderTool.m
//  lame4iOS
//
//  Created by 晓童 韩 on 16/1/25.
//  Copyright © 2016年 晓童 韩. All rights reserved.
//

#import "XTMP3EncoderTool.h"
#import <lame/lame.h>


@implementation XTMP3EncoderTool

+ (void)convertFromWav:(NSString *)wavPath toMp3:(NSString *)mp3Path block:(ConvertCompletionBlock)compblock {
    
    DDLogDebug(@"WAV Path: %@", wavPath);
    DDLogDebug(@"MP3 Path: %@", mp3Path);
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([wavPath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3Path cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_num_channels(lame, 2);
        lame_set_in_samplerate(lame, 44100.0/2);
        lame_set_brate(lame, 16);
        lame_set_quality(lame, 5);
        lame_set_VBR(lame, vbr_off);
        lame_init_params(lame);
        
        DDLogDebug(@"%d", lame_get_out_samplerate(lame));
        DDLogDebug(@"%d", lame_get_num_channels(lame));
        DDLogDebug(@"%d", lame_get_brate(lame));
        DDLogDebug(@"%d", lame_get_quality(lame));
        DDLogDebug(@"%d", lame_get_VBR(lame));
        
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        DDLogDebug(@"转换mp3到: %@", mp3Path);
    }
    @catch (NSException *exception) {
        DDLogDebug(@"exception:%@",[exception description]);
    }
    @finally {
        //[self performSelectorOnMainThread:@selector(didConvertMp3) withObject:nil waitUntilDone:YES];
        DDLogDebug(@"转换mp3成功");
        compblock(YES);
    }
}

//+ (void)didConvertMp3 {
//    
//}

@end

