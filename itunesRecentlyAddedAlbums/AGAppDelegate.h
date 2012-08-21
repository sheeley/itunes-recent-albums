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

@interface AGAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSPopUpButton *fromPlaylistPopUp;
    IBOutlet NSPopUpButton *toPlaylistSinglesPopUp;
    IBOutlet NSPopUpButton *toPlaylistAlbumsPopUp;
    IBOutlet NSPopUpButton *minSongPopUp;
    IBOutlet NSPopUpButton *maxAlbumPopUp;
    IBOutlet NSTextView *outputField;
    IBOutlet NSButton *clearSinglesPlaylistButton;
    IBOutlet NSButton *clearAlbumsPlaylistButton;
    IBOutlet NSProgressIndicator *spinner;
    IBOutlet NSPopUpButton *repeatButton;
    IBOutlet NSButton *goButton;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) AGItunes *agItunes;

@property (nonatomic, retain) NSTimer *runTimer;

@property (nonatomic, retain) IBOutlet NSPopUpButton *fromPlaylistPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *toPlaylistSinglesPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *toPlaylistAlbumsPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *minSongPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *maxAlbumPopUp;
@property (nonatomic, retain) IBOutlet NSTextView *outputField;
@property (nonatomic, retain) IBOutlet NSButton *clearSinglesPlaylistButton;
@property (nonatomic, retain) IBOutlet NSButton *clearAlbumsPlaylistButton;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *spinner;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) IBOutlet NSPopUpButton *repeatButton;
@property (nonatomic, retain) IBOutlet NSButton *goButton;

- (IBAction) arrangeTracks: (id) sender;
- (AGRunConfig *) getRunConfig;
- (IBAction) refreshPlaylists: (id) sender;
- (void) saveSettings;
- (void) loadSettings;
- (void) populateForm;
- (IBAction)updateRepeat:(id)sender;

@end
