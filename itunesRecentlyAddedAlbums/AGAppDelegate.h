//
//  AGAppDelegate.h
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AGItunes.h"

@interface AGAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSPopUpButton *fromPlaylistPopUp;
    IBOutlet NSPopUpButton *toPlaylistPopUp;
    IBOutlet NSPopUpButton *minSongPopUp;
    IBOutlet NSPopUpButton *maxAlbumPopUp;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) AGItunes *agItunes;

@property (nonatomic, retain) IBOutlet NSPopUpButton *fromPlaylistPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *toPlaylistPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *minSongPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *maxAlbumPopUp;

-(IBAction)arrangeTracks:(id)sender;
-(bool) validateFromPlaylist: (NSString *) fromName andToName: (NSString *) toName andMinSongs: (int) minSongs andMaxAlbums: (int) maxAlbums;

@end
