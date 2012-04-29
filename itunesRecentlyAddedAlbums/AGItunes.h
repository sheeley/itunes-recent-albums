//
//  AGItunes.h
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/SBApplication.h>
#import "iTunes.h"

@interface AGItunes : NSObject

- (iTunesApplication *) getItunes;

- (SBElementArray *) getItunesPlaylists;
- (bool) albumTitleIsBad: (NSString *) albumTitle;
- (iTunesPlaylist *) getPlaylistWithName: (NSString *) playlistName;
- (NSDictionary *) getSongsFromPlaylist: (NSString *) playlistName;
- (void) createNewPlaylist: (NSString *) playlistName FromDictionary: (NSDictionary *) albums andMinTracks: (NSInteger) minTracks andMaxAlbums: (int)maxAlbums;

@end
