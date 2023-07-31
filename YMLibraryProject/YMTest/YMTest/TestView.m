//
//  TestView.m
//  ToDesk
//
//  Created by 黄玉洲 on 2022/6/22.
//

#import "TestView.h"
#import "YMCMDLibrary.h"
#import "YMCustomTextField.h"
@interface TestView () <NSInputServiceProvider, YMCustomTextFieldDelegate>
{
    NSTrackingArea*        trackingArea;
}

@property (strong, nonatomic) YMTerminal * terminal;
@property (strong, nonatomic) YMCustomTextField * textField;

@end

@implementation TestView



- (void)layoutSubtreeIfNeeded {
    [super layoutSubtreeIfNeeded];
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    NSButton * button = [[NSButton alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
    button.title = @"button1";
    button.action = @selector(button1Action);
    button.target = self;
    [self addSubview:button];
    
    self.textField = [[YMCustomTextField alloc] init];
    self.textField.frame = CGRectMake(100, 200, 100, 100);
    self.textField.ymDelegate = self;
    self.textField.wantsLayer = YES;
    self.textField.layer.borderColor = [NSColor grayColor].CGColor;
    self.textField.layer.borderWidth = 0.5;
    self.textField.backgroundColor = [NSColor redColor];
    [self addSubview:self.textField];
    

}

- (void)button1Action {
    // getcwd()获取当前工作目录的绝对值路径
    size_t size = PATH_MAX;
    char *buffer = (char *)malloc(size);
    NSLog(@"%s", getcwd(buffer, size));
    free(buffer);
    
    if (!self.terminal) {
        YMTerminal * terminal = [[YMTerminal alloc] init];
        terminal.commandOutputHandler = ^(NSString * _Nonnull output) {
            NSLog(@"output:%@", output);
        };
        [terminal startTerminal];
        [terminal runCommand:@" "];
        
        self.terminal = [[YMTerminal alloc] init];
        [self.terminal startTerminal];
        self.terminal.terminationHandler = ^(YMTerminal * _Nonnull terminal) {
            NSLog(@"终止");
        };

        self.terminal.commandOutputHandler = ^(NSString * _Nonnull output) {
            NSLog(@"%@\n", output);
        };
    } else {
//        [self.terminal runCommand:@"cd ~/ImageResources;"];
        [self.terminal runCommand:self.textField.stringValue];
    }
    
//    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"string_2" ofType:@"txt"];
//    NSString * string = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"UTF8:%s", [string UTF8String]);
}

- (BOOL)matchPredicate:(NSString *)regex forContent:(NSString *)content {
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    bool match = [pre evaluateWithObject:content];
    return match;
}

#pragma mark - <YMCustomTextFieldDelegate>
- (void)ymTextDidTouchKey:(YMCustomTextField *)textField keyType:(kCustomTextFieldKey)keyType {
    if (keyType == kCustomTextFieldKey_Enter) {
        [self button1Action];
    }
}

#pragma mark - 界面指针监听
- (void)mouseListerning {
    //    if(trackingArea) {
    //      [self removeTrackingArea:trackingArea];
    //    }
            
    //    NSTrackingAreaOptions opts =
    //    NSTrackingMouseEnteredAndExited
    //    | NSTrackingMouseMoved
    //    //| NSTrackingCursorUpdate
    //    | NSTrackingActiveAlways
    //    | NSTrackingInVisibleRect;
    //
    //    trackingArea = [[NSTrackingArea alloc] initWithRect:self.frame
    //        options: opts
    //        owner:self userInfo:nil];
    //    [self addTrackingArea:trackingArea];
    //    self.nextKeyView = self;
        
        /* 成为第一响应者 */
    //    [[self window] setAcceptsMouseMovedEvents:YES];
    //    [[self window] makeFirstResponder:self];
}

//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//
//    // Drawing code here.
//}
//
//- (void)mouseMoved:(NSEvent *)theEvent
//{
//    [super mouseMoved:theEvent];
//    NSLog(@"%s", __func__);
//}
//
//- (void)mouseDown:(NSEvent *)theEvent
//{
//    [super mouseDown:theEvent];
//    NSLog(@"%s", __func__);
//}
//
//- (void)mouseUp:(NSEvent *)theEvent
//{
//    [super mouseUp:theEvent];
//    NSLog(@"%s", __func__);
//}
//
//- (void)mouseDragged:(NSEvent *)theEvent
//{
//    [super mouseDragged:theEvent];
//    NSLog(@"%s", __func__);
//}
//
//- (void)otherMouseDragged:(NSEvent *)theEvent {
//    [super mouseDragged:theEvent];
//    NSLog(@"%s", __func__);
//}

//- (BOOL)acceptsFirstResponder
//{
//    return YES;
//}
//
//- (BOOL)becomeFirstResponder {
//    return YES;
//}
//
//- (BOOL) canBecomeKeyWindow {
//    return true;
//}
//
//- (void)keyDown:(NSEvent *)theEvent {
//    NSLog(@"%s key_code:%d flags:%d", __func__, theEvent.keyCode, theEvent.modifierFlags);
//}
//
//- (void)keyUp:(NSEvent *)theEvent {
//    NSLog(@"%s key_code:%d flags:%d", __func__, theEvent.keyCode, theEvent.modifierFlags);
//}
//
//- (void)flagsChanged:(NSEvent *)theEvent {
//    NSLog(@"%s key_code:%d flags:%d", __func__, theEvent.keyCode, theEvent.modifierFlags);
//}

@end
