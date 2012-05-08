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

extern NSString * const NON_ALBUM_TITLE;

- (iTunesApplication *) getItunes;
- (SBElementArray *) getItunesPlaylists;
- (bool) albumTitleIsBad: (NSString *) albumTitle;
- (iTunesUserPlaylist *) getPlaylistWithName: (NSString *) playlistName;
- (NSDictionary *) getSongsFromPlaylist: (NSString *) fromPlaylistName;
-(void) clearPlaylistWithName: (NSString *) playlistName;
- (void) clearPlaylist: (iTunesPlaylist *) playlist;
- (void) moveSinglesTo: (NSString *) toPlaylistNameSingles andAlbumsTo: (NSString *)toPlaylistNameAlbums FromDictionary: (NSDictionary *)albums andMinTracks:(int) minTracks andMaxAlbums: (int) maxAlbums;



@end
