//
//  AGAppDelegate.h
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AGItunes.h"
#import "AGUtils.h"

@interface AGAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (strong, nonatomic) AGItunes *agItunes;
@property (strong, nonatomic) NSTimer *runTimer;

@property (weak) IBOutlet NSPopUpButton *fromPlaylistPopUp;
@property (weak) IBOutlet NSPopUpButton *toPlaylistSinglesPopUp;
@property (weak) IBOutlet NSPopUpButton *toPlaylistAlbumsPopUp;
@property (weak) IBOutlet NSPopUpButton *minSongPopUp;
@property (weak) IBOutlet NSPopUpButton *maxAlbumPopUp;
@property (assign) IBOutlet NSTextView *outputField;
@property (weak) IBOutlet NSButton *clearSinglesPlaylistButton;
@property (weak) IBOutlet NSButton *clearAlbumsPlaylistButton;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) NSTimer *timer;
@property (weak) IBOutlet NSPopUpButton *repeatButton;
@property (weak) IBOutlet NSButton *goButton;

- (IBAction) arrangeTracks: (id) sender;
- (AGRunConfig *) getRunConfig;
- (IBAction) refreshPlaylists: (id) sender;
- (void) saveSettings;
- (void) loadSettings;
- (void) populateForm;
- (IBAction)updateRepeat:(id)sender;

@end
