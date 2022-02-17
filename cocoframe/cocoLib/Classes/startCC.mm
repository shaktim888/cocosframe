#include "startCC.h"
#import "CCAppController.h"

void startCC()
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    UIApplicationMain(0, NULL, nil, NSStringFromClass([CCAppController class]));
    [pool release];
}

id startBB()
{
    return [[CCAppController alloc] init];
}
