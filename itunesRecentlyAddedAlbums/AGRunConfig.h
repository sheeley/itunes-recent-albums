//
//  AGRunConfig.h
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGRunConfig : NSObject

@property (nonatomic, retain) NSString *fromPlaylist;
@property (nonatomic, retain) NSString *toPlaylistSingles;
@property (nonatomic, retain) NSString *toPlaylistAlbums;

@property int minTracksPerAlbum;
@property int maxAlbumsToProcess;
@property int maxTracksToIngest;

@property bool doClearSinglesPlaylist;
@property bool doClearAlbumsPlaylist;
           
@end
