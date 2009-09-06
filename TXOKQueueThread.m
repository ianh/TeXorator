//
//  TXOKQueueThread.m
//  TeXorator
//
//  Created by Ian Henderson on 10.26.08.
//

#import "TXOKQueueThread.h"

#include <sys/event.h>
#include <sys/time.h>
#include <sys/types.h>

@implementation TXOKQueueThread

- (void)threadMain:(id)_arg
{
    int kq;
    struct kevent event;
    
    kq = kqueue();
    if (kq < 0) {
        // error
        NSLog(@"kqueue failure");
    }
    
    int fileDesc;
    int i;
reopen:
    fileDesc = 0;
    for (i=0; i<10 && fileDesc <= 0; i++) {
        fileDesc = open(path, O_EVTONLY);
        if (fileDesc <= 0) {
            usleep(100000);
        }
    }
    if (fileDesc <= 0) {
        // error
        NSLog(@"filedesc failure");
        return;
    }
    
    EV_SET(&event, fileDesc, EVFILT_VNODE, EV_ADD | EV_ENABLE | EV_CLEAR, NOTE_WRITE | NOTE_DELETE, 0, NULL);
    struct timespec nullts = {0,0};
    kevent(kq, &event, 1, NULL, 0, &nullts);
    
    NSAutoreleasePool *pool;
update:
    pool = [[NSAutoreleasePool alloc] init];
    [delegate fileChanged];
    [pool release];
    
loop:
    
    pool = [[NSAutoreleasePool alloc] init];
    if ([[NSThread currentThread] isCancelled]) {
        [pool release];
        goto done;
    }
    [pool release];
    
    struct timespec timeout;
    timeout.tv_sec = 0;
    timeout.tv_nsec = 500000000;
    int eventCount = kevent(kq, NULL, 0, &event, 1, &timeout);
    
    if (eventCount < 0 || event.flags == EV_ERROR) {
        goto done;
    }
    
    if (eventCount > 0) {
        if (event.fflags & NOTE_DELETE) {
            goto reopen;
        } else {
            goto update;
        }
    }
    
    goto loop;
    
done:
    close(fileDesc);
}

- (id)initWithDelegate:(id)_delegate path:(const char *)_path
{
    if (![super init]) {
        return nil;
    }
    delegate = _delegate;
    strncpy(path, _path, 1024);
    return self;
}

@end
