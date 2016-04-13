//
//  AppDelegate.m
//  OEM-Tools
//
//  Created by zhoujianfeng on 16/3/14.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

/**
 *  点击窗口关闭按钮结束应用程序
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
