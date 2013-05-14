//
//  ServersPreferencesViewController.m
//  sshproxy
//
//  Created by Brant Young on 14/5/13.
//  Copyright (c) 2013 Charm Studio. All rights reserved.
//

#import "ServersPreferencesViewController.h"
#import "CharmNumberFormatter.h"

@implementation ServersPreferencesViewController

#pragma mark -
#pragma mark MASPreferencesViewController

- (id)init
{
    return [super initWithNibName:@"ServersPreferencesView" bundle:nil];
}

- (NSString *)identifier
{
    return @"ServersPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameNetwork];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Servers", @"Toolbar item name for the Servers preference pane");
}

-(void)awakeFromNib
{
    CharmNumberFormatter *formatter = [[CharmNumberFormatter alloc] init];
    [remotePortTextField setFormatter:formatter];
    
    NSInteger remotePort = [[NSUserDefaults standardUserDefaults] integerForKey:@"remote_port"];
    if (remotePort<=0 || remotePort>65535) {
        remotePort = 22;
    }
    [remotePortTextField setIntegerValue:remotePort];
    
    NSInteger localPort = [[NSUserDefaults standardUserDefaults] integerForKey:@"local_port"];
    if (localPort<=0 || localPort>65535) {
        localPort = 7070;
    }
    
    [remotePortStepper setIntegerValue:remotePort];
}

- (IBAction)remoteStepperAction:(id)sender {
	[remotePortTextField setIntValue: [remotePortStepper intValue]];
}

- (IBAction) showTheSheet:(id)sender {
    [NSApp beginSheet:advancedPanel
       modalForWindow:self.view.window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

-(IBAction)endTheSheet:(id)sender {
    [NSApp endSheet:advancedPanel];
    [advancedPanel orderOut:sender];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)addServer:(id)sender {
    NSMutableDictionary* defaultServer = [[NSMutableDictionary alloc] init];
    
    [defaultServer setObject:@"example.com" forKey:@"remote_host"];
    [defaultServer setObject:[NSNumber numberWithInt:22] forKey:@"remote_port"];
    [defaultServer setObject:@"user" forKey:@"login_name"];
    [defaultServer setObject:[NSNumber numberWithBool:NO] forKey:@"enable_compression"];
    [defaultServer setObject:[NSNumber numberWithBool:NO] forKey:@"share_socks"];
    
    [self.serverArrayController addObject:defaultServer];
}

-(IBAction)closePreferencesWindow:(id)sender {
    [self.view.window orderOut:nil];
}

@end