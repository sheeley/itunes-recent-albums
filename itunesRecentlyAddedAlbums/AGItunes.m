//
//  AGItunes.m
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AGItunes.h"
#import "AGUtils.h"

@implementation AGItunes

@synthesize runData, runConfig;

- (id)init
{
    return [self initWithConfig:nil];
}

- (id) initWithConfig: (AGRunConfig *) config
{
    if (self = [super init])
    {
        self.runData = [[AGRunData alloc] init];   
        self.runConfig = config;
    }
    return self;
}

- (iTunesApplication *) getItunes {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    if(![iTunes isRunning]){
        [iTunes run];
    }
    return iTunes;
}

- (SBElementArray *) getItunesPlaylists
{
    iTunesApplication *iTunes = [self getItunes];    
    SBElementArray *sources = [iTunes sources];
    iTunesSource *source = [sources objectWithName:@"Library"];
    if(source != nil){
        return [source userPlaylists];
    }
    return nil;    
}

- (bool) albumTitleIsBad: (NSString *) albumTitle 
{
    // TODO
    return false;
}

- (iTunesUserPlaylist *) getPlaylistWithName: (NSString *) playlistName
{
    SBElementArray *playlists = [self getItunesPlaylists];
    return [playlists objectWithName:playlistName];
}

- (AGRunData *) arrangeSongs
{
    if(runConfig == nil /*|| ![runConfig isValid]*/){
        return nil;
    }
    
    NSString *fromPlaylistName = runConfig.fromPlaylist;
    NSString *toPlaylistNameSingles = runConfig.toPlaylistSingles;
    NSString *toPlaylistNameAlbums = runConfig.toPlaylistAlbums;
    
    self.runData.startTime = [[NSDate alloc] init];
    
    NSDictionary *tracks = [self getSongsFromPlaylist:fromPlaylistName];
    if(tracks == nil){
        // from playlist doesn't exist
        NSString *error = [NSString stringWithFormat:@"playlist %@ doesn't seem to exist", fromPlaylistName];
        [self.runData logError:error];
    } else if([tracks count] == 0){
        // no tracks or tracks with no albums in the playlist
        NSString *error = [NSString stringWithFormat: @"playlist %@ seems to be empty", fromPlaylistName];
        [self.runData logError:error];
    } else {
        if(self.runConfig.doClearSinglesPlaylist && toPlaylistNameSingles != nil){
            [self clearPlaylistWithName:toPlaylistNameSingles andContext:SINGLES_CONTEXT];
        }
        if(self.runConfig.doClearAlbumsPlaylist && toPlaylistNameAlbums != nil){
            [self clearPlaylistWithName:toPlaylistNameAlbums andContext:ALBUM_CONTEXT];            
        }
        [self moveTracksFromDictionary: tracks]; 
        [[self getItunes] activate];
    }
    
    self.runData.endTime = [[NSDate alloc] init];
    return self.runData;
}

- (NSDictionary *) getSongsFromPlaylist: (NSString *) fromPlaylistName
{
    iTunesUserPlaylist *playlist = [self getPlaylistWithName:fromPlaylistName];
    if(playlist == nil) return nil;
    
    SBElementArray *tracks = [playlist tracks];
    NSString *message = [NSString stringWithFormat:@"%d tracks in source playlist", [tracks count]];
    [self.runData logMessage:message];
    NSMutableDictionary *albums = [[NSMutableDictionary alloc] init];
    NSMutableArray *singles = [[NSMutableArray alloc] init];
    
    for(iTunesTrack *track in tracks){
        if(self.runData.tracksIngested > self.runConfig.maxTracksToIngest){
            message = [NSString stringWithFormat:@"Hit %d tracks, done reading", self.runConfig.maxTracksToIngest];
            [self.runData logMessage:message];
            break;
        }
        
        NSString *albumTitle = [AGUtils stripString:[track album]];
        if(([track trackNumber] == 0 && [[track name] length] == 0) || [self albumTitleIsBad: albumTitle]){
            message = [NSString stringWithFormat:@"SKIPPING: %@", [track name]];
            [self.runData logMessage:message];
            continue;
        }
        
        if(albumTitle == nil || [albumTitle length] == 0){
            [singles addObject:track];
        } else {
            NSMutableArray *currAlbum = [albums objectForKey:albumTitle];
            if(currAlbum == nil){
                currAlbum = [[NSMutableArray alloc] init];
            }
            [currAlbum addObject:track];
            [albums setValue:currAlbum forKey:albumTitle];
        }
        self.runData.tracksIngested++;
    }
    message = [NSString stringWithFormat:@"%d total tracks injested", self.runData.tracksIngested];
    [self.runData logMessage:message];
    
    NSMutableDictionary *oTracks = [[NSMutableDictionary alloc] init];
    if([singles count] > 0){
        [oTracks setObject:singles forKey:SINGLES_CONTEXT];
    }
    
    if([albums count] > 0){
        [oTracks setObject:albums forKey:ALBUM_CONTEXT];
    }
    return oTracks;
}
- (void) setFromPlaylist: (NSString *) fromPlaylist andToPlaylistSingles: (NSString *) singlesPlaylist andToPlaylistAlbums: (NSString *) albumsPlaylist
andMinTracks: (int) minTracks andMaxAlbums: (int) maxAlbums
{
    self.runData.toPlaylistSingles = singlesPlaylist;
    self.runData.toPlaylistAlbums = albumsPlaylist;
    self.runData.fromPlaylist = fromPlaylist;
    self.runData.maxAlbumsToProcess = maxAlbums;
    self.runData.minTracksPerAlbum = minTracks;
}

-(void) clearPlaylistWithName: (NSString *) playlistName andContext: (NSString *) context
{
    iTunesUserPlaylist *playlist = [self getPlaylistWithName:playlistName];
    if(playlist != nil){
        [self clearPlaylist:playlist andContext:context];
    }
}

- (void) clearPlaylist: (iTunesPlaylist *) playlist andContext: (NSString *) context
{
    SBElementArray *tracks = [playlist tracks];
    int trackCount = [tracks count];

    int deletedCount = 0;
    // have to delete backwards because they shift up
    for(int i = trackCount; i>=0; i--){
        iTunesTrack *track = [tracks objectAtIndex:i];
        [track delete];
        deletedCount++;
    } 
    
    if(context == ALBUM_CONTEXT){
        self.runData.albumTracksDeleted = deletedCount;
    } else if(context == ALBUM_CONTEXT){
        self.runData.singleTracksDeleted = deletedCount;
    }
    NSString *message = [NSString stringWithFormat:@"%d tracks deleted", deletedCount];
    [self.runData logMessage:message];
}

- (void) moveTracksFromDictionary: (NSDictionary *) albums 
{
    [self moveSinglesTo:self.runConfig.toPlaylistSingles andAlbumsTo:self.runConfig.toPlaylistAlbums FromDictionary:albums andMinTracks:self.runConfig.minTracksPerAlbum andMaxAlbums:self.runConfig.maxAlbumsToProcess];
}

- (void) moveSinglesTo: (NSString *) toPlaylistNameSingles andAlbumsTo: (NSString *)toPlaylistNameAlbums FromDictionary: (NSDictionary *) allTracks andMinTracks:(int) minTracks andMaxAlbums: (int) maxAlbums
{
    if(allTracks == nil) return;
    
    NSMutableArray *singles = [allTracks objectForKey:SINGLES_CONTEXT]; 
    NSString *message = [NSString stringWithFormat:@"original singles count: %lu", [singles count]];
    [self.runData logMessage:message];
    NSDictionary *albums = [allTracks objectForKey:ALBUM_CONTEXT];
    NSMutableArray *albumKeys = [[NSMutableArray alloc] init];
    self.runData.totalAlbums = [albums count];
    
    // split albums from singles
    for(NSString *albumTitle in albums){
        NSArray *album = [albums objectForKey:albumTitle];
        if([album count] >= minTracks){
            [albumKeys addObject:[album objectAtIndex:0]];
        } else {
            [singles addObjectsFromArray:album];
        }   
    }
    
    // handle albums    
    if(toPlaylistNameAlbums != nil){
        iTunesUserPlaylist *albumsPlaylist = [self getPlaylistWithName:toPlaylistNameAlbums];
        if(albumsPlaylist != nil){
            NSArray *sortedAlbumKeys = [albumKeys sortedArrayUsingComparator:^NSComparisonResult(iTunesTrack *t1, iTunesTrack *t2) {
                return [[t2 dateAdded] compare: [t1 dateAdded]];
            }];
            for(iTunesTrack *track in sortedAlbumKeys){
                NSArray *album = [albums objectForKey:[track album]];
                self.runData.totalAlbumTracksAdded += [self addSongs:album toPlayList:albumsPlaylist andIdentifier:@"there"];
                self.runData.albumsProcessed++;
                if(self.runData.albumsProcessed > maxAlbums){
                    break;
                }
            }
        }
    }

    // handle singles
    if(toPlaylistNameSingles != nil){
        message = [NSString stringWithFormat:@"new singles count: %lu", [singles count]];
        [self.runData logMessage:message];
        iTunesUserPlaylist *singlesPlaylist = [self getPlaylistWithName:toPlaylistNameSingles];
        if(singlesPlaylist != nil && singles != nil){
            self.runData.totalSinglesTracksAdded += [self addSongs:singles toPlayList:singlesPlaylist andIdentifier:@"singles"];
        }
    }

    message = [NSString stringWithFormat:@"%d albums (out of %d total) added with %d songs to %@", self.runData.albumsProcessed, self.runData.totalAlbums, self.runData.totalAlbumTracksAdded, toPlaylistNameAlbums];
    [self.runData logMessage:message];
    message = [NSString stringWithFormat:@"%d singles added to %@", self.runData.totalSinglesTracksAdded, toPlaylistNameSingles];
    [self.runData logMessage:message];
}

- (int) addSongs: (NSArray *) albumTracks toPlayList: (iTunesPlaylist *) playlist andIdentifier: (NSString *) ident
{
    int count = 0;
    if([ident isEqualToString:@"singles"]){
        albumTracks = [albumTracks sortedArrayUsingComparator:^NSComparisonResult(iTunesTrack *t1, iTunesTrack *t2) {
            return [[t2 dateAdded] compare: [t1 dateAdded]];
        }];
    } else {
        albumTracks = [albumTracks sortedArrayUsingComparator:^NSComparisonResult(iTunesTrack *t1, iTunesTrack *t2) {
            if([t1 trackNumber] != 0 && [t2 trackNumber] != 0){
                return [t1 trackNumber] > [t2 trackNumber];
            } else {
                NSString *t1c = ([t1 trackNumber] != 0) ? [NSString stringWithFormat:@"%d",[t1 trackNumber]] : [t1 name];
                NSString *t2c = ([t2 trackNumber] != 0) ? [NSString stringWithFormat:@"%d",[t2 trackNumber] ]: [t2 name];
                return [t1c compare:t2c];
            }
        }];
    }
    
    for(iTunesTrack *track in albumTracks){
        [track duplicateTo:playlist];
        count++;
    }
    return count;
}
@end
