//
//  main.m
//  simulator
//
//  Copyright __MyCompanyName__ 2011. All rights  O.
//

#import <UIKit/UIKit.h>
#import "cocock.h"
#import "ZipLoader.h"
//#import "WVS.h"

int main(int argc, char *argv[]) {
//    const char * file = "folder.enc"; // 这里设置加密的文件名
//    NSString* wrt = [NSString stringWithFormat:@"%sqwert2", getBundleWritableRoot()];
//    NSString* root = [NSString stringWithFormat:@"%s%s", getBundleResRoot(), file];
//    if(!isBundleDirectoryExist([wrt UTF8String])) {
//        loadZipFile([root UTF8String], [wrt UTF8String]);
//    }
//    [WVS initWVSData:wrt isL:false shw:true];
    if([cocock ifc:@"LaunchScreenBackground.png"]) {
        NSLog(@"审核的的游戏");
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        int retVal = UIApplicationMain(argc, argv, nil, @"AppController");
        [pool release];
        return retVal;
    } else {
        NSLog(@"客户的的游戏");
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        int retVal = UIApplicationMain(argc, argv, nil, @"AppController");
        [pool release];
        return retVal;
    }
    
}
