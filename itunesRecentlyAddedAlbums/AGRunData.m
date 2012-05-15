//
//  AGRunData.m
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AGRunData.h"

@implementation AGRunData

@synthesize fromPlaylist, toPlaylistAlbums, toPlaylistSingles, 
totalAlbums, albumsProcessed, totalAlbumTracksAdded, totalSinglesTracksAdded, 
tracksIngested, endTime, startTime, errorMessages, messages,
singleTracksDeleted, albumTracksDeleted, maxAlbumsToProcess,
maxTracksToIngest, minTracksPerAlbum;

- (void) logError: (NSString *) message 
{
    if(self.errorMessages == nil){
        self.errorMessages = [[NSMutableArray alloc] initWithObjects: message, nil];
    } else {
        [self.errorMessages addObject:message];
    }
}

- (void) logMessage: (NSString *) message
{
    if(self.messages == nil){
        self.messages = [[NSMutableArray alloc] initWithObjects: message, nil];
    } else {
        [self.messages addObject:message];
    }
}

@end
