//
//  TXOPreferencesController.h
//  TeXorator
//
//  Created by Ian Henderson on 24.09.04.
//

#import <Cocoa/Cocoa.h>


@interface TXOPreferencesController : NSWindowController {
    IBOutlet NSTextField *executablePath;
}

- (IBAction)ok:(id)sender;

@end
