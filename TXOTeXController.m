//
//  TXOTeXController.m
//  TeXorator
//
//  Created by Ian Henderson on 23.09.04.
//

#import "TXOTeXController.h"

@interface NSObject(TXOTexControllerDelegate)

- (void)texControllerFinishedWithNoError;
- (void)texControllerFinishedWithError;

@end


@implementation TXOTeXController


- (void)setupThreading
{
    if (notificationQueue) return;
    notificationQueue  = [[NSMutableArray alloc] init];
    notificationLock   = [[NSLock alloc] init];
    notificationThread = [[NSThread currentThread] retain];

    notificationPort = [[NSMachPort alloc] init];
    [notificationPort setDelegate:self];
    [[NSRunLoop currentRunLoop] addPort:notificationPort forMode:(NSString *)kCFRunLoopCommonModes];
}

- (void)handleMachMessage:(void *)msg {
    [notificationLock lock];
    while ([notificationQueue count]) {
        NSString *filename = [[notificationQueue objectAtIndex:0] retain];
        [notificationQueue removeObjectAtIndex:0];
        [notificationLock unlock];
        [self processTexFile:filename];
        [filename release];
        [notificationLock lock];
    };
    [notificationLock unlock];
}

- (NSString *)executablePath
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"TXOTexExecutable"];
}

- (void)processTexFile:(NSString *)fileName delegate:object
{
    delegate = object;
    [self processTexFile:fileName];
}

- (void)processTexFile:(NSString *)fileName
{
    if ([NSThread currentThread] != notificationThread) {
        // Forward the notification to the correct thread
        [notificationLock lock];
        [notificationQueue addObject:fileName];
        [notificationLock unlock];
        [notificationPort sendBeforeDate:[NSDate date]
                              components:nil
                                    from:nil
                                reserved:0];
        return;
    }
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"--interaction=nonstopmode"];
    [args addObject:[[fileName pathComponents] lastObject]];

    if ([pdfLatexTask isRunning]) {
        [pdfLatexTask terminate];
    }
    [pdfLatexTask release];
    pdfLatexTask = [[NSTask alloc] init];

    [pdfLatexTask setCurrentDirectoryPath:[fileName stringByDeletingLastPathComponent]];
    [pdfLatexTask setLaunchPath:[self executablePath]];
    [pdfLatexTask setArguments:args];

    [outputPipe release];
    outputPipe = [[NSPipe alloc] init];
    [pdfLatexTask setStandardOutput:outputPipe];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskFinished:)
                                                 name:NSTaskDidTerminateNotification
                                               object:pdfLatexTask];
    [pdfLatexTask launch];
}

- (void)taskFinished:notification
{
    NSData *data = [[outputPipe fileHandleForReading] readDataToEndOfFile];
    NSMutableString *mungedString = [NSMutableString string];
    if (data != nil) {
        NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        int i;
        BOOL lastCharWasNewline = NO;
        BOOL mungingCharacters = NO;
        BOOL newlineHasBeenMunged = NO;
        NSCharacterSet *newlineCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
        unichar character;
        for (i=0; i<[dataString length]; i++) {
            character = [dataString characterAtIndex:i];

            if (mungingCharacters && lastCharWasNewline && ![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:character]) {
                if (newlineHasBeenMunged) {
                    mungingCharacters = NO;
                    newlineHasBeenMunged = NO;
                } else {
                    newlineHasBeenMunged = YES;
                }
            }

            if (mungingCharacters) {
                [mungedString appendString:[NSString stringWithCharacters:&character length:1]];
            } else if (lastCharWasNewline && character == '!') {
                mungingCharacters = YES;
            }

            if ([newlineCharacterSet characterIsMember:character]) {
                lastCharWasNewline = YES;
            } else {
                lastCharWasNewline = NO;
            }
        }

        [self window];
        [texOutput setString:mungedString];
    }

    if ([mungedString length] == 0) {
        if ([delegate respondsToSelector:@selector(texControllerFinishedWithNoError)]) {
            [delegate texControllerFinishedWithNoError];
        }
    } else {
        if ([delegate respondsToSelector:@selector(texControllerFinishedWithError)]) {
            [delegate texControllerFinishedWithError];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([pdfLatexTask isRunning]) {
        [pdfLatexTask terminate];
    }
    [pdfLatexTask release];
    pdfLatexTask = nil;
    [outputPipe release];
    outputPipe = nil;
}

- (void)dealloc
{
    if ([pdfLatexTask isRunning]) {
        [pdfLatexTask terminate];
    }
    [pdfLatexTask release];
    [outputPipe release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
