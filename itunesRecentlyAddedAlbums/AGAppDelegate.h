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
    IBOutlet NSTextField *outputField;
    IBOutlet NSButton *clearSinglesPlaylistButton;
    IBOutlet NSButton *clearAlbumsPlaylistButton;
}

/*enum AGItunesSettings {
    SAMPLE
} 
typedef enum AGItunesSettings AGItunesSettings;*/

extern NSString * const SETTINGS_KEY;
extern NSString * const NO_PLAYLIST;
extern NSString * const SOURCE_PLAYLIST;
extern NSString * const TO_ALBUM_PLAYLIST;
extern NSString * const TO_SINGLE_PLAYLIST;
extern NSString * const CLEAR_TO_SINGLE_PLAYLIST;
extern NSString * const CLEAR_TO_ALBUM_PLAYLIST;
extern NSString * const MAX_ALBUMS;
extern NSString * const MIN_SONGS_PER_ALBUM;

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) AGItunes *agItunes;

@property (nonatomic, retain) IBOutlet NSPopUpButton *fromPlaylistPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *toPlaylistSinglesPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *toPlaylistAlbumsPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *minSongPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton *maxAlbumPopUp;
@property (nonatomic, retain) IBOutlet NSTextField *outputField;
@property (nonatomic, retain) IBOutlet NSButton *clearSinglesPlaylistButton;
@property (nonatomic, retain) IBOutlet NSButton *clearAlbumsPlaylistButton;

- (void) populateForm;
-(IBAction) arrangeTracks:(id)sender;
-(bool) validateFromPlaylist: (NSString *) fromName andToSinglesName: (NSString *) toSinglesName andToAlbumsName: (NSString *) toAlbumsName andMinSongs: (int) minSongs andMaxAlbums: (int) maxAlbums;
-(void) saveSettings;
-(void) loadSettings;
-(void) log: (NSString *) logString;

@end
