//
//  TXOPreferencesController.m
//  TeXorator
//
//  Created by Ian Henderson on 24.09.04.
//

#import "TXOPreferencesController.h"

NSString * const TXODefaultExecutablePath = @"/usr/texbin/pdflatex";

@implementation TXOPreferencesController

- (id)init
{
    return [super initWithWindowNibName:@"TXOPreferences"];
}

- (IBAction)ok:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[executablePath stringValue] forKey:@"TXOTexExecutable"];
    [self close];
}

- (void)windowDidLoad
{
    [executablePath setStringValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"TXOTexExecutable"]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)note
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:TXODefaultExecutablePath forKey:@"TXOTexExecutable"]];
}

@end
