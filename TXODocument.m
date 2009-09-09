//
//  TXODocument.m
//  TeXorator
//
//  Created by Ian Henderson on 23.09.04.
//

#import "TXODocument.h"
#import "TXOTeXController.h"
#import "TXOKQueueThread.h"
#include <Quartz/Quartz.h>

@implementation TXODocument

- (void)dealloc
{
    [subThread cancel];
    while (![subThread isFinished]) { }
    [subThread release];
    
    [kQueue release];
    [pdfDocument release];
    [super dealloc];
}

- (void)fileChanged
{
    [texController processTexFile:[self fileName] delegate:self];
}

- (void)texControllerFinishedWithNoError
{
    [[texController window] close];
    
    BOOL preserveLayout = (pdfDocument != nil);
    
    PDFDestination *dest = [pdfView currentDestination];
    NSPoint pt = [dest point];
    NSUInteger pageIdx = [pdfDocument indexForPage:[dest page]];
    
    [pdfDocument release];
    pdfDocument = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:[[[self fileName] stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"]]];
    [pdfView setDocument:pdfDocument];
    
    if (preserveLayout) {
        dest = [[PDFDestination alloc] initWithPage:[pdfDocument pageAtIndex:pageIdx] atPoint:pt];
        [pdfView goToDestination:dest];
        [dest release];
    }
}

- (void)texControllerFinishedWithError
{
    [texController showWindow:self];
}

- (NSString *)windowNibName
{
    return @"TXODocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    [pdfView setAutoScales:YES];
    [texController setupThreading];
    if (!subThread) {
        kQueue = [[TXOKQueueThread alloc] initWithDelegate:self path:[[[self fileURL] path] UTF8String]];
        subThread = [[NSThread alloc] initWithTarget:kQueue selector:@selector(threadMain:) object:nil];
        [subThread start];
    }
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    return nil;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    // Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
    return YES;
}

- (void)printShowingPrintPanel:(BOOL)showPanels 
{
    NSPrintOperation *op = [NSPrintOperation printOperationWithView:pdfView printInfo:[self printInfo]];
    [op setShowPanels:showPanels];
    
    [self runModalPrintOperation:op delegate:nil didRunSelector:NULL contextInfo:NULL];
}

@end
