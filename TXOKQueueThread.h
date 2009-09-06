//
//  TXOKQueueThread.h
//  TeXorator
//
//  Created by Ian Henderson on 10.26.08.
//

#import <Cocoa/Cocoa.h>


@interface TXOKQueueThread : NSObject {
    id delegate;
    char path[1024];
}

- (id)initWithDelegate:(id)_delegate path:(const char *)_path;

- (void)threadMain:(id)_arg;

@end
