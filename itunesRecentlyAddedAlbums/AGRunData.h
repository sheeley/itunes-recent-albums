//
//  AGRunData.h
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGUtils.h"

@interface AGRunData : NSObject

@property (nonatomic, retain) NSString *fromPlaylist;
@property (nonatomic, retain) NSString *toPlaylistSingles;
@property (nonatomic, retain) NSString *toPlaylistAlbums;

@property int minTracksPerAlbum;
@property int maxAlbumsToProcess;
@property int maxTracksToIngest;

@property int singleTracksDeleted;
@property int albumTracksDeleted;

@property int tracksIngested;
@property int totalAlbums;
@property int albumsProcessed;
@property int totalAlbumTracksAdded;
@property int totalSinglesTracksAdded;

@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;

@property (nonatomic, retain) NSMutableArray *errorMessages;
@property (nonatomic, retain) NSMutableArray *messages;

- (void) logError: (NSString *) message;
- (void) logMessage: (NSString *) message;
- (NSString *) toString;

@end
