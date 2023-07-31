//
//  AppDelegate.m
//  ToDesk
//
//  Created by Li xiangwei on 2021/2/1.
//

#import "AppDelegate.h"
@interface AppDelegate()
@property (strong, nonatomic) NSMutableArray * array;
@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // 主控制器
    _mainWindows = [[MainWindowController alloc]initWithWindowNibName:@"MainWindowController"];
    [[_mainWindows window] center];
    [_mainWindows.window orderFront:nil];
    
//    int width = 6016;
//    int height = 3384;
//    int ppi = 218;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//
//    width = 5120;
//    height = 2880;
//    ppi = 218;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 4096;
//    height = 2304;
//    ppi = 219;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 3840;
//    height = 2400;
//    ppi = 200;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//
//    width = 3840;
//    height = 2160;
//    ppi = 200;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//
//    width = 3840;
//    height = 1600;
//    ppi = 200;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//
//    width = 3840;
//    height = 1080;
//    ppi = 200;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 3072;
//    height = 1920;
//    ppi = 226;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 2880 ;
//    height = 1800;
//    ppi = 220;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 2560;
//    height = 1600;
//    ppi = 227;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 2560;
//    height = 1440;
//    ppi = 109;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 2304 ;
//    height = 1440;
//    ppi = 226;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 2048;
//    height = 1536;
//    ppi = 150;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 2048;
//    height = 1152;
//    ppi = 150;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 1920;
//    height = 1200;
//    ppi = 150;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 1600;
//    height = 900;
//    ppi = 125;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 1920;
//    height = 1080;
//    ppi = 102;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 1680;
//    height = 1050;
//    ppi = 99;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    
//    width = 1440;
//    height = 900;
//    ppi = 127;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 1400;
//    height = 1050;
//    ppi = 125;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 1366;
//    height = 768;
//    ppi = 135;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//    
//    width = 1280;
//    height = 1024;
//    ppi = 100;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
//
//    width = 1280;
//    height = 800;
//    ppi = 113;
//    NSLog(@"width:%d height:%d ppi:%d inches = %.2f", width, height, ppi, sqrt(pow(width, 2) + pow(height, 2)) / ppi);
}

@end
