//
//  main.m
//  cocospod
//
//  Created by admin on 11/14/2019.
//  Copyright (c) 2019 admin. All rights reserved.
//

@import UIKit;
#import "CSAppDelegate.h"
//#include <cocoframe/startCC.h>
#include <cocoframelib/startCC.h>

int main(int argc, char * argv[])
{
    startCC();
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CSAppDelegate class]));
    }
}
