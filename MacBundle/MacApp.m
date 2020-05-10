#import "MacApp.h"

@implementation MacApp

+ (void)removeMenuItems {
    NSMenu *menu = [[NSApplication sharedApplication] mainMenu];
    NSArray *array = [menu itemArray];
    id first = array.firstObject;
    for (id item in array) {
        if (item != first) {
            [menu removeItem: item];
        }
    }
}

+ (void)disableZoom {
    NSWindow *window = [[[NSApplication sharedApplication] windows] firstObject];
    NSButton *button = [window standardWindowButton: NSWindowZoomButton];
    [button setEnabled: NO];
}

+ (void)enableZoom {
    NSWindow *window = [[[NSApplication sharedApplication] windows] firstObject];
    NSButton *button = [window standardWindowButton: NSWindowZoomButton];
    [button setEnabled: YES];
}

+ (void)toggleFullScreen {
    
    NSWindow *window = [[[NSApplication sharedApplication] windows] firstObject];
    BOOL isFullScreen = ((window.styleMask & NSWindowStyleMaskFullScreen) == NSWindowStyleMaskFullScreen);
    
    if (isFullScreen) {
        [window toggleFullScreen:nil];
    }
}

@end
