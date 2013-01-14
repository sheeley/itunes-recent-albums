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
#import "AGRunConfig.h"

@interface AGItunes : NSObject

@property (strong, nonatomic) AGRunConfig *runConfig;
@property (strong, nonatomic) iTunesApplication *iTunes;

- (id) initWithConfig: (AGRunConfig *) config;
- (void) setConfig: (AGRunConfig *) config;
- (iTunesApplication *) getItunes;
- (SBElementArray *) getItunesPlaylists;
- (iTunesUserPlaylist *) getPlaylistWithName: (NSString *) playlistName;
- (void) arrangeSongs;//: (void (^)(AGRunData *output))block;
- (void) notify: (NSString *) message;

@end
