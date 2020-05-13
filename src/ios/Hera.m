/********* XinGe.m Cordova Plugin Implementation *******/

#import <UIKit/UIKit.h>
#import <Hera/WDHodoer.h>
#import "Hera.h"
#import <Hera/WHHybridExtension.h>


@implementation Hera

- (void)open:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *args = [command argumentAtIndex:0];
    NSString   *appId  = [args objectForKey:@"appid"];
    NSString   *userId  = [args objectForKey:@"userid"];
    NSString   *appPath  = [args objectForKey:@"apppath"];
//    [[WWIMManager shareManager] ww_loginWithUserName:username token:token];
    WDHAppInfo *appInfo = [[WDHAppInfo alloc] init];
    //小程序标识
    appInfo.appId = appId;

    //标识宿主app业务用户id
    appInfo.userId =userId;

    //小程序资源zip路径,如果为空或未找到资源 则读取MainBundle下以appId命名的资源包(appId.zip)
    appInfo.appPath = appPath;
    NSString * stringPath =[NSString stringWithFormat:@"%@.zip",appInfo.appId];
    NSURL* startURL = [NSURL URLWithString:stringPath];
    NSString* startFilePath = [self.commandDelegate pathForResource:[startURL path]];
    
    appInfo.appPath = startFilePath;
    
    [self.indicatorView startAnimating];
    
    WDHSystemConfig *config = [WDHSystemConfig sharedConfig];
    config.enableLog = NO;

        //兼容H5页面调用
        UIViewController* topmostVC = [self topViewController];
        if(topmostVC!=nil){
            //启动
            [[WDHInterface sharedInterface] startAppWithAppInfo:appInfo entrance:topmostVC completion:^(BOOL success, NSString *msg) {
                [self.indicatorView stopAnimating];

                NSLog(@"%@", msg);
            }];
        }
//    [[WDHInterface sharedInterface] startAppWithAppInfo:appInfo entrance:self.navigationController completion:^(BOOL success, NSString *msg) {
//        [self.indicatorView stopAnimating];
//
//        NSLog(@"%@", msg);
//    }];
}
- (void)start:(CDVInvokedUrlCommand *)command {
    //注册自实现API
    [self configHera];
}


- (void)configHera {

    UIViewController* topmostVC = [self topViewController];
    if(topmostVC!=nil){
        //启动
        [WHHybridExtension registerExtensionApi:@"openPage" handler:^id(id param) {
                UIViewController *vc = [[UIViewController alloc] init];
                UINavigationController *navi = (UINavigationController *)topmostVC;
                [navi pushViewController:vc animated:YES];
                
                return @{WDHExtensionKeyCode:@(WDHExtensionCodeSuccess)};
            }];
            
//            [WHHybridExtension registerExtensionApi:@"openLink" handler:^id(id param) {
//                LinkViewController *vc = [[LinkViewController alloc] init];
//                vc.url = param[@"url"];
//                UINavigationController *navi = (UINavigationController *)topmostVC;
//                [navi pushViewController:vc animated:YES];
//        
//                return @{WDHExtensionKeyCode:@(WDHExtensionCodeSuccess)};
//            }];
//        
//            [WHHybridExtension registerRetrieveApi:@"getResult" handler:^id(id param, WDHApiCompletion completion) {
//        
//                RetrieveViewController *vc = [[RetrieveViewController alloc] init];
//                if([vc respondsToSelector:@selector(didReceiveApi:withParam:completion:)]){
//                    [vc didReceiveApi:@"getResult" withParam:param completion:completion];
//                }
//                UINavigationController *navi = (UINavigationController *)topmostVC;
//                [navi pushViewController:vc animated:YES];
//        
//                return @{WDHExtensionKeyCode:@(WDHExtensionCodeSuccess)};
//            }];
    }
}


- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}
@end
