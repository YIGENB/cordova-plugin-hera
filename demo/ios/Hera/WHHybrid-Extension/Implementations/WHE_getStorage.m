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


#import "WHE_getStorage.h"
#import "WHHybridExtension.h"
#import "WHEStorageUtil.h"
#import "WDHAppInfo.h"
#import "WDHApp.h"
#import "WDHAppManager.h"
#import "WDHFileManager.h"

@implementation WHE_getStorage

- (void)setupApiWithSuccess:(void (^)(NSDictionary<NSString *,id> * _Nonnull))success failure:(void (^)(id _Nullable))failure cancel:(void (^)(void))cancel {
    
    if (!self.key) {
        failure(@{@"errMsg": @"参数key为空"});
        return;
    }
    
    // 获取当前用户storage文件
	WDHApp *app = [[WDHAppManager sharedManager] currentApp];
    NSString *storageDirPath = [WDHFileManager appStorageDirPath:app.appInfo.appId];
    NSString *userId = app.appInfo.userId;
    NSString *filePath = [NSString stringWithFormat:@"%@/storage_%@", storageDirPath, userId];
    
    NSDictionary *dic = [WHEStorageUtil dictionaryWithFilePath:filePath];
    id data = [dic objectForKey:self.key];
    
    if (data) {
        NSString *dataType = nil;
        if ([data isKindOfClass:NSNumber.class]) {
            dataType = @"Number";
        } else if ([data isKindOfClass:NSString.class]) {
            dataType = @"String";
        } else if ([data isKindOfClass:NSDictionary.class]) {
            dataType = @"Dictionary";
        } else if ([data isKindOfClass:NSArray.class]) {
            dataType = @"Array";
        } else if ([data isKindOfClass:NSDate.class]) {
            dataType = @"Date";
        } else {
            dataType = @"Undefined";
        }
        
        success(@{@"data": data, @"dataType": dataType});
    } else {
        failure(@{@"errMsg": @"找不到key 对应的数据"});
    }
}

@end

