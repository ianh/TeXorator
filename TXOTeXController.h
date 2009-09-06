//
//  TXOTeXController.h
//  TeXorator
//
//  Created by Ian Henderson on 23.09.04.
//

#import <Cocoa/Cocoa.h>


@interface TXOTeXController : NSWindowController {
	IBOutlet NSTextView *texOutput;
	
	id delegate;
	NSPipe *outputPipe;
	NSTask *pdfLatexTask;
	
	// Icky threading stuff
	NSMutableArray *notificationQueue;
    NSThread *notificationThread;
    NSLock *notificationLock;
    NSMachPort *notificationPort;
}

- (void)setupThreading;

- (void)processTexFile:(NSString *)fileName;
- (void)processTexFile:(NSString *)fileName delegate:object;

@end
