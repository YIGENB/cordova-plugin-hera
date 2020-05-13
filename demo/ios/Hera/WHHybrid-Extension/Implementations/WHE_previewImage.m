//
// Copyright (c) 2017, weidian.com
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "WHE_previewImage.h"
#import "WHECommonUtil.h"
#import "WHEMacro.h"
#import "WDHAppManager.h"
#import "WDHApp.h"
#import "WDHFileManager.h"
#import "WDHAppInfo.h"
#import "WDHPhotoPreviewView.h"

@implementation WHE_previewImage

- (void)setupApiWithSuccess:(void(^_Null_unspecified)(NSDictionary<NSString *, id> * _Nonnull))success
                    failure:(void(^_Null_unspecified)(id _Nullable))failure
                     cancel:(void(^_Null_unspecified)(void))cancel
{
    if (!self.urls || self.urls.count <= 0) {
        failure(@{@"errMsg": @"参数urls为空"});
        return;
    }
    
    NSArray *imageArray = [self parseUrls];
    
    NSUInteger selectIndex = 0;
    if (self.current) {
        NSUInteger index = [self.urls indexOfObject:self.current];
        if (index == NSNotFound) {
            index = 0;
        }
        
        selectIndex = index;
    }
    
    BOOL statusBarEnable = [UIApplication sharedApplication].isStatusBarHidden;
    [WDHPhotoPreviewView showWithImgs:imageArray
                        selectedIndex:selectIndex
                    selectedImageView:nil
                      allVisibleViews:nil
                           closeBlock:^(NSInteger currentIndex) {
                               [[UIApplication sharedApplication] setStatusBarHidden:statusBarEnable];
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (NSArray *)parseUrls {
    
    NSMutableArray *arr = [NSMutableArray array];
	WDHApp *app = [[WDHAppManager sharedManager] currentApp];
    for(NSString *url in self.urls) {
        if ([url hasPrefix:[WDH_FILE_SCHEMA stringByAppendingString:@"tmp_"]]) {
            NSString *fileName = [self getFileName:url];
            NSString *filePath = [[WDHFileManager appTempDirPath:app.appInfo.appId] stringByAppendingPathComponent:fileName];
            NSString *fileUrl = [[NSURL fileURLWithPath:filePath] absoluteString];
            [arr addObject:fileUrl];
        } else if ([url hasPrefix:[WDH_FILE_SCHEMA stringByAppendingString:@"store_"]]) {
            NSString *fileName = [self getFileName:url];
            NSString *filePath = [[WDHFileManager appPersistentDirPath:app.appInfo.appId] stringByAppendingPathComponent:fileName];
            NSString *fileUrl = [[NSURL fileURLWithPath:filePath] absoluteString];
            [arr addObject:fileUrl];
        } else {
            [arr addObject:url];
        }
    }
    
    return arr;
}

- (NSString *)getFileName:(NSString *)filePath {
    
    NSRange range = [filePath rangeOfString: WDH_FILE_SCHEMA];
    NSString *fileName = [filePath substringFromIndex:NSMaxRange(range)];
    
    return fileName;
}

@end

