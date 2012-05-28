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
#import "AGRunData.h"
#import "AGRunConfig.h"

@interface AGItunes : NSObject

@property (nonatomic, retain) AGRunData *runData;
@property (nonatomic, retain) AGRunConfig *runConfig;

- (id) initWithConfig: (AGRunConfig *) config;
- (iTunesApplication *) getItunes;
- (SBElementArray *) getItunesPlaylists;
- (iTunesUserPlaylist *) getPlaylistWithName: (NSString *) playlistName;
- (AGRunData *) arrangeSongsUpdateUIWithBlock: (void (^)(AGRunData *output))block;

@end
