//
//  ViewController.m
//  lame4iOS
//
//  Created by 晓童 韩 on 16/1/25.
//  Copyright © 2016年 晓童 韩. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "XTMP3EncoderTool.h"

#define DocPath ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject])
#define AudioFilename  @"MyRecord"
#define MP3Path ([DocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", AudioFilename]])
#define WAVPath ([DocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav", AudioFilename]])


@interface ViewController ()

@property (nonatomic, strong) AVAudioPlayer *wavPlayer;

@property (nonatomic, strong) AVAudioPlayer *mp3Player;

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机

@property (nonatomic, strong) NSDictionary *settingDict;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)buttonDidClick:(UIButton *)button {
    switch (button.tag) {
        case 0: {
            DDLogDebug(@"录音");
            [self stopAllPlayer];
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            //设置为播放和录音状态，以便可以在录制完之后播放录音
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            [audioSession setActive:YES error:nil];
            if (![self.audioRecorder isRecording]) {
                [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
            }
            break;
        }
        case 1: {
            DDLogDebug(@"停止录音");
            [self stopRecorder];
            break;
        }
        case 2:
            DDLogDebug(@"转换音频");
            [self stopAllPlayer];
            [self stopRecorder];
            if (![[NSFileManager defaultManager] fileExistsAtPath:WAVPath]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"额。。请先录音。。" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好吧。。" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }
            [XTMP3EncoderTool convertFromWav:WAVPath toMp3:MP3Path block:^(BOOL isDone) {
                if(isDone){
                    DDLogDebug(@"转换文件成功");
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"转换文件成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }];
            break;
    }
}


- (IBAction)playButtonDidClick:(UIButton *)button {
    DDLogDebug(@"%ld", (long)button.tag);
    switch (button.tag) {
        case 0: {
            DDLogDebug(@"播放WAV");
            [self stopAllPlayer];
            [self stopRecorder];
            if (![[NSFileManager defaultManager] fileExistsAtPath:WAVPath]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"额。。请先录音。。" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好吧。。" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }
            [self.wavPlayer play];
            break;
        }
        case 1: {
            DDLogDebug(@"播放MP3");
            [self stopAllPlayer];
            [self stopRecorder];
            if (![[NSFileManager defaultManager] fileExistsAtPath:MP3Path]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"额。。请先转换MP3文件。。" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好吧。。" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }
            [self.mp3Player play];
            break;
        }
        default:
            [self stopAllPlayer];
            DDLogDebug(@"停止播放");
            break;
    }
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)settingDict
{
    if (_settingDict) {
        _settingDict = @{
                         AVFormatIDKey : @(kAudioFormatLinearPCM),
                         AVSampleRateKey : @(44100.0),//设置录音采样率
                         AVNumberOfChannelsKey : @(1),//设置通道的数目
                         AVLinearPCMBitDepthKey : @(16),//每个采样点位数,分为8、16、24、32
                         AVLinearPCMIsFloatKey : @(NO),//采样信号是整数还是浮点数
                         AVLinearPCMIsBigEndianKey : @(NO)//大端还是小端是内存的组织方式
                         };
    }
    
    return _settingDict;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        NSURL *url = [NSURL fileURLWithPath:WAVPath];
        //创建录音机
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.settingDict error:&error];
//        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
        if (error) {
            DDLogDebug(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

- (AVAudioPlayer *)wavPlayer {
    if (!_wavPlayer) {
        NSURL *url = [NSURL fileURLWithPath:WAVPath];
        NSError *error = nil;
        _wavPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _wavPlayer.numberOfLoops = 0;//不循环
        [_wavPlayer prepareToPlay];
        if (error) {
            DDLogDebug(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _wavPlayer;
}

- (AVAudioPlayer *)mp3Player {
    if (!_mp3Player) {
        NSURL *url = [NSURL fileURLWithPath:MP3Path];
        NSError *error = nil;
        _mp3Player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _mp3Player.numberOfLoops = 0;//不循环
        [_mp3Player prepareToPlay];
        if (error) {
            DDLogDebug(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _mp3Player;
}


- (void)stopAllPlayer {
    if (_wavPlayer && [self.wavPlayer isPlaying]) {
        [self.wavPlayer stop];
        self.wavPlayer  = nil;
    }
    if (_mp3Player && [self.mp3Player isPlaying]) {
        [self.mp3Player stop];
        self.mp3Player  = nil;
    }
}

- (void)stopRecorder {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];  //此处需要恢复设置回放标志，否则会导致其它播放声音也会变小
    [session setActive:YES error:nil];
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder stop];
    }
}
@end
