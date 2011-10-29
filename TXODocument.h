//
//  TXODocument.h
//  TeXorator
//
//  Created by Ian Henderson on 23.09.04.
//

#include <sys/event.h>
#include <sys/types.h>
#import <Cocoa/Cocoa.h>

@class PDFView, PDFDocument, TXOTeXController, TXOKQueueThread;

@interface TXODocument : NSDocument
{
    IBOutlet PDFView *pdfView;
    IBOutlet TXOTeXController *texController;

    PDFDocument *pdfDocument;

    TXOKQueueThread *kQueue;
    NSThread *subThread;
}

- (void)fileChanged;

@end
