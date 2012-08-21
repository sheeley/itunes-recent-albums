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

@synthesize runConfig, iTunes;

- (id)init
{
    return [self initWithConfig:nil];
}

- (id) initWithConfig: (AGRunConfig *) config
{
    if (self = [super init])
    {
        self.runConfig = config;
    }
    return self;
}

- (void) setConfig: (AGRunConfig *) config {
    self.runConfig = config;
}

- (iTunesApplication *) getItunes {
    if(self.iTunes == nil){
        self.iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        if([iTunes respondsToSelector:@selector(sources)]){
            if(![iTunes isRunning]){
                [iTunes run];
            }
        } else {
            self.iTunes = nil;
        }
    }
    return self.iTunes;
}

- (SBElementArray *) getItunesPlaylists
{
    iTunesApplication *_iTunes = [self getItunes];
    if(_iTunes != nil){
        SBElementArray *sources = [_iTunes sources];
        iTunesSource *source = [sources objectWithName:@"Library"];
        if(source != nil){
            return [source userPlaylists];
        }
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
    if(playlists != nil){
        return [playlists objectWithName:playlistName];
    }
    return nil;
}

- (AGRunData *) arrangeSongsUpdateUIWithBlock: (void (^)(AGRunData *output))block
{    
    if(runConfig == nil /*|| ![runConfig isValid]*/){
        return nil;
    }
    AGRunData *runData = [[AGRunData alloc] init];
    
    NSString *fromPlaylistName = runConfig.fromPlaylist;
    NSString *toPlaylistNameSingles = runConfig.toPlaylistSingles;
    NSString *toPlaylistNameAlbums = runConfig.toPlaylistAlbums;
    
    runData.startTime = [[NSDate alloc] init];
    // TODO: hide itunes, much better performance while hidden
    NSDictionary *tracks = [self getSongsFromPlaylist:fromPlaylistName andRunData:runData];
    block(runData);
    if(tracks == nil){
        // from playlist doesn't exist
        NSString *error = [NSString stringWithFormat:@"playlist %@ doesn't seem to exist", fromPlaylistName];
        [runData logError:error];
    } else if([tracks count] == 0){
        // no tracks or tracks with no albums in the playlist
        NSString *error = [NSString stringWithFormat: @"playlist %@ seems to be empty", fromPlaylistName];
        [runData logError:error];
    } else {
        if(self.runConfig.doClearSinglesPlaylist && toPlaylistNameSingles != nil){
            [self clearPlaylistWithName:toPlaylistNameSingles andContext:SINGLES_CONTEXT andRunData:runData];
        }
        if(self.runConfig.doClearAlbumsPlaylist && toPlaylistNameAlbums != nil){
            [self clearPlaylistWithName:toPlaylistNameAlbums andContext:ALBUM_CONTEXT andRunData:runData];
        }
        block(runData);
        [self moveTracksFromDictionary: tracks andRunData:runData];
        //[[self getItunes] activate];
    }

    runData.endTime = [[NSDate alloc] init];
    block(runData);
    return runData;
}

- (NSDictionary *) getSongsFromPlaylist: (NSString *) fromPlaylistName andRunData: (AGRunData *) runData
{
    iTunesUserPlaylist *playlist = [self getPlaylistWithName:fromPlaylistName];
    if(playlist == nil) return nil;
    
    SBElementArray *tracks = [playlist tracks];
    NSString *message = [NSString stringWithFormat:@"%ld tracks in source playlist", [tracks count]];
    [runData logMessage:message];
    NSMutableDictionary *albums = [[NSMutableDictionary alloc] init];
    NSMutableArray *singles = [[NSMutableArray alloc] init];
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\.(com|org|net)" options:NSRegularExpressionCaseInsensitive error:&error];
    if(error != nil){
        DLog(@"%@", error);
    }
    
    for(iTunesTrack *track in tracks){
        if(runData.tracksIngested > self.runConfig.maxTracksToIngest){
            message = [NSString stringWithFormat:@"Hit %d tracks, done reading", self.runConfig.maxTracksToIngest];
            [runData logMessage:message];
            break;
        }        

        NSString *albumTitle = [AGUtils stripString:[track album]];
        if(([track trackNumber] == 0 && [[track name] length] == 0)){
            message = [NSString stringWithFormat:@"SKIPPING: %@", [track name]];
            [runData logMessage:message];
            continue;
        }
        
        if(albumTitle == nil || [albumTitle length] == 0 ||
           [regex numberOfMatchesInString:albumTitle options:0 range:NSMakeRange(0, [albumTitle length])] > 0 ){
            [singles addObject:track];
        } else {
            NSMutableArray *currAlbum = [albums objectForKey:albumTitle];
            if(currAlbum == nil){
                currAlbum = [[NSMutableArray alloc] init];
            }
            [currAlbum addObject:track];
            [albums setValue:currAlbum forKey:albumTitle];
        }
        runData.tracksIngested++;
    }
    message = [NSString stringWithFormat:@"%d total tracks injested", runData.tracksIngested];
    [runData logMessage:message];
    
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
            andMinTracks: (int) minTracks andMaxAlbums: (int) maxAlbums andRunData: (AGRunData *) runData
{
    runData.toPlaylistSingles = singlesPlaylist;
    runData.toPlaylistAlbums = albumsPlaylist;
    runData.fromPlaylist = fromPlaylist;
    runData.maxAlbumsToProcess = maxAlbums;
    runData.minTracksPerAlbum = minTracks;
}

-(void) clearPlaylistWithName: (NSString *) playlistName andContext: (NSString *) context andRunData: (AGRunData *) runData
{
    iTunesUserPlaylist *playlist = [self getPlaylistWithName:playlistName];
    if(playlist != nil){
        [self clearPlaylist:playlist andContext:context andRunData:runData];
    }
}

- (void) clearPlaylist: (iTunesPlaylist *) playlist andContext: (NSString *) context andRunData: (AGRunData *) runData
{
    SBElementArray *tracks = [playlist tracks];
    long trackCount = [tracks count];

    int deletedCount = 0;
    // have to delete backwards because they shift up
    for(long i = trackCount; i>=0; i--){
        iTunesTrack *track = [tracks objectAtIndex:i];
        [track delete];
        deletedCount++;
    } 
    
    if(context == ALBUM_CONTEXT){
        runData.albumTracksDeleted = deletedCount;
    } else if(context == ALBUM_CONTEXT){
        runData.singleTracksDeleted = deletedCount;
    }
    NSString *message = [NSString stringWithFormat:@"%d tracks deleted", deletedCount];
    [runData logMessage:message];
}

- (void) moveTracksFromDictionary: (NSDictionary *) albums andRunData: (AGRunData *) runData
{
    [self moveSinglesTo:self.runConfig.toPlaylistSingles andAlbumsTo:self.runConfig.toPlaylistAlbums FromDictionary:albums andMinTracks:self.runConfig.minTracksPerAlbum andMaxAlbums:self.runConfig.maxAlbumsToProcess andRunData:runData];
}

- (void) moveSinglesTo: (NSString *) toPlaylistNameSingles andAlbumsTo: (NSString *)toPlaylistNameAlbums FromDictionary: (NSDictionary *) allTracks andMinTracks:(int) minTracks andMaxAlbums: (int) maxAlbums andRunData: (AGRunData *) runData
{
    if(allTracks == nil) return;
    
    NSMutableArray *singles = [allTracks objectForKey:SINGLES_CONTEXT]; 
    NSString *message = [NSString stringWithFormat:@"original singles count: %lu", [singles count]];
    [runData logMessage:message];
    NSDictionary *albums = [allTracks objectForKey:ALBUM_CONTEXT];
    NSMutableArray *albumKeys = [[NSMutableArray alloc] init];
    runData.totalAlbums = [albums count];
    
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
                runData.totalAlbumTracksAdded += [self addSongs:album toPlayList:albumsPlaylist andIdentifier:@"there"];
                runData.albumsProcessed++;
                if(runData.albumsProcessed > maxAlbums){
                    break;
                }
            }
        }
    }

    // handle singles
    if(toPlaylistNameSingles != nil){
        message = [NSString stringWithFormat:@"new singles count: %lu", [singles count]];
        [runData logMessage:message];
        iTunesUserPlaylist *singlesPlaylist = [self getPlaylistWithName:toPlaylistNameSingles];
        if(singlesPlaylist != nil && singles != nil){
            runData.totalSinglesTracksAdded += [self addSongs:singles toPlayList:singlesPlaylist andIdentifier:@"singles"];
        }
    }

    message = [NSString stringWithFormat:@"%d albums (out of %d total) added with %d songs to %@", runData.albumsProcessed, runData.totalAlbums, runData.totalAlbumTracksAdded, toPlaylistNameAlbums];
    [runData logMessage:message];
    message = [NSString stringWithFormat:@"%d singles added to %@", runData.totalSinglesTracksAdded, toPlaylistNameSingles];
    [runData logMessage:message];
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
                NSString *t1c = ([t1 trackNumber] != 0) ? [NSString stringWithFormat:@"%ld",[t1 trackNumber]] : [t1 name];
                NSString *t2c = ([t2 trackNumber] != 0) ? [NSString stringWithFormat:@"%ld",[t2 trackNumber] ]: [t2 name];
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
