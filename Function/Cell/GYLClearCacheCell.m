//
//  GYLClearCachaCell.m
//  GUBaiSI
//
//  Created by 永亮 谷 on 8/3/16.
//  Copyright © 2016 Recluse. All rights reserved.
//

#import "GYLClearCacheCell.h"
#import <SDImageCache.h>
#import <SVProgressHUD.h>

#define GYLCustomFile [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"MP3"]

@implementation GYLClearCacheCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loadingView startAnimating];
        self.accessoryView = loadingView;
        
        self.textLabel.text = @"清楚缓存";
//        [self.textLabel setTextColor:[UIColor blueColor]];
        self.detailTextLabel.text = @"正在计算";
        
        self.userInteractionEnabled = NO;
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:1.0];
            
//            NSString *customFileCache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"MP3"];
            
            unsigned long long size = GYLCustomFile.fileSize;
            GYLLog(@"customFile -size:%zd",size);
            
            size += [SDImageCache sharedImageCache].getSize;   //SDImage 缓存
            GYLLog(@"%zd",[SDImageCache sharedImageCache].getSize);
            
            
            GYLLog(@"allFile -size:%zd",size);
            
            if (weakSelf == nil) return;
            
            NSString *sizeText = nil;
            if (size >= pow(10, 9)) {
                sizeText = [NSString stringWithFormat:@"%.2fGB", size / pow(10, 9)];
            }else if (size >= pow(10, 6)) {
                sizeText = [NSString stringWithFormat:@"%.2fMB", size / pow(10, 6)];
            }else if (size >= pow(10, 3)) {
                sizeText = [NSString stringWithFormat:@"%.2fKB", size / pow(10, 3)];
            }else {
                sizeText = [NSString stringWithFormat:@"%zdB", size];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.detailTextLabel.text = [NSString stringWithFormat:@"%@",sizeText];
                weakSelf.accessoryView = nil;
                weakSelf.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                [weakSelf addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(clearCacheClick)]];
                
                weakSelf.userInteractionEnabled = YES;
                
            });
            
        });
        
    }
    
    return self;
}

- (void)clearCacheClick
{
    [SVProgressHUD showWithStatus:@"正在清除缓存···"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           
            [NSThread sleepForTimeInterval:2.0];
            
            NSFileManager *mgr = [NSFileManager defaultManager];
            [mgr removeItemAtPath:GYLCustomFile error:nil];
            [mgr createDirectoryAtPath:GYLCustomFile withIntermediateDirectories:YES attributes:nil error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [SVProgressHUD dismiss];
                
                // 设置文字
                self.detailTextLabel.text = nil;
                
            });
            
        });
    }];
}

/**
 *  当cell重新显示到屏幕上时, 也会调用一次layoutSubviews
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // cell重新显示的时候, 继续转圈圈
    UIActivityIndicatorView *loadingView = (UIActivityIndicatorView *)self.accessoryView;
    [loadingView startAnimating];
}


@end
