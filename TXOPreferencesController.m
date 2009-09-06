//
//  TXOPreferencesController.m
//  TeXorator
//
//  Created by Ian Henderson on 24.09.04.
//

#import "TXOPreferencesController.h"


@implementation TXOPreferencesController

- init
{
	return [super initWithWindowNibName:@"TXOPreferences"];
}

- (IBAction)ok:sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[executablePath stringValue] forKey:@"TXOTexExecutable"];
	[self close];
}

- (void)windowDidLoad
{
	NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"TXOTexExecutable"];
	if (path == nil) {
		[[NSUserDefaults standardUserDefaults] setObject:DEFAULT_PATH forKey:@"TXOTexExecutable"];
		path = DEFAULT_PATH;
	}
	[executablePath setStringValue:path];
}

@end
