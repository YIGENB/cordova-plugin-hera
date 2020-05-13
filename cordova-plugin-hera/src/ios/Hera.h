/********* XinGe.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>
#import <Hera/WDHodoer.h>


@interface Hera : CDVPlugin<UINavigationControllerDelegate> {
  // Member variables go here.
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;


- (void)start:(CDVInvokedUrlCommand*)command;
- (void)open:(CDVInvokedUrlCommand*)command;
@end

