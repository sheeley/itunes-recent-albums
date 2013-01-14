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
    if(_iTunes == nil){
        _iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        if([_iTunes respondsToSelector:@selector(sources)]){
            if(![_iTunes isRunning]){
                [_iTunes run];
            }
        } else {
            self.iTunes = nil;
        }
    }
    return self.iTunes;
}

- (SBElementArray *) getItunesPlaylists
{
    [self getItunes];
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

- (void) arrangeSongs;
{    
    if(_runConfig == nil){
        return;
    }
    
    NSString *fromPlaylistName = _runConfig.fromPlaylist;
    NSString *toPlaylistNameSingles = _runConfig.toPlaylistSingles;
    NSString *toPlaylistNameAlbums = _runConfig.toPlaylistAlbums;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *startDate = [[NSDate alloc] init];
    [self notify: [NSString stringWithFormat:@"Start Date: %@", [dateFormatter stringFromDate:startDate]]];
    // TODO: hide itunes, much better performance while hidden
    NSDictionary *tracks = [self getSongsFromPlaylist:fromPlaylistName];// andRunData:runData];
                                                                        // block(runData);
    if(tracks == nil){
        [self notify:[NSString stringWithFormat:@"playlist %@ doesn't seem to exist", fromPlaylistName]];
    } else if([tracks count] == 0){
        [self notify:[NSString stringWithFormat: @"playlist %@ seems to be empty", fromPlaylistName]];
    } else {
        if(self.runConfig.doClearSinglesPlaylist && toPlaylistNameSingles != nil){
            [self clearPlaylistWithName:toPlaylistNameSingles andContext:SINGLES_CONTEXT]; //andRunData:runData];
        }
        if(self.runConfig.doClearAlbumsPlaylist && toPlaylistNameAlbums != nil){
            [self clearPlaylistWithName:toPlaylistNameAlbums andContext:ALBUM_CONTEXT]; //andRunData:runData];
        }
        [self moveTracksFromDictionary: tracks];
        //[[self getItunes] activate];
    }

    NSDate *endDate = [[NSDate alloc] init];
    [self notify: [NSString stringWithFormat:@"End Date: %@", [dateFormatter stringFromDate:endDate]]];
    [self notify: [NSString stringWithFormat:@"Seconds elapsed: %f", fabs([startDate timeIntervalSinceNow])]];
}

- (NSDictionary *) getSongsFromPlaylist: (NSString *) fromPlaylistName// //andRunData: (AGRunData *) runData
{
    iTunesUserPlaylist *playlist = [self getPlaylistWithName:fromPlaylistName];
    if(playlist == nil) return nil;
    
    SBElementArray *tracks = [playlist tracks];
    [self notify: [NSString stringWithFormat:@"%ld tracks in source playlist", [tracks count]]];
    NSMutableDictionary *albums = [[NSMutableDictionary alloc] init];
    NSMutableArray *singles = [[NSMutableArray alloc] init];
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\.(com|org|net)" options:NSRegularExpressionCaseInsensitive error:&error];
    if(error != nil){
        DLog(@"%@", error);
    }
    
    int tracksIngested = 0;
    for(iTunesTrack *track in tracks){
        if(tracksIngested > self.runConfig.maxTracksToIngest){
            [self notify: [NSString stringWithFormat:@"Hit %d tracks, done reading", self.runConfig.maxTracksToIngest]];
            break;
        }        

        NSString *albumTitle = [AGUtils stripString:[track album]];
        if(([track trackNumber] == 0 && [[track name] length] == 0)){
            [self notify: [NSString stringWithFormat:@"SKIPPING: %@", [track name]]];
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
        tracksIngested++;
    }
    [self notify: [NSString stringWithFormat:@"%d total tracks injested", tracksIngested]];
    
    NSMutableDictionary *oTracks = [[NSMutableDictionary alloc] init];
    if([singles count] > 0){
        [oTracks setObject:singles forKey:SINGLES_CONTEXT];
    }
    
    if([albums count] > 0){
        [oTracks setObject:albums forKey:ALBUM_CONTEXT];
    }
    return oTracks;
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
    long trackCount = [tracks count];

    int deletedCount = 0;
    // have to delete backwards because they shift up
    for(long i = trackCount; i>=0; i--){
        iTunesTrack *track = [tracks objectAtIndex:i];
        [track delete];
        deletedCount++;
    } 
    
    NSString *message = [NSString stringWithFormat:@"%d tracks deleted from playlist %@", deletedCount, [playlist name]];
    [self notify: message];
}

- (void) moveTracksFromDictionary: (NSDictionary *) albums
{
    [self moveSinglesTo:self.runConfig.toPlaylistSingles andAlbumsTo:self.runConfig.toPlaylistAlbums FromDictionary:albums andMinTracks:self.runConfig.minTracksPerAlbum andMaxAlbums:self.runConfig.maxAlbumsToProcess];
}

- (void) moveSinglesTo: (NSString *) toPlaylistNameSingles andAlbumsTo: (NSString *)toPlaylistNameAlbums FromDictionary: (NSDictionary *) allTracks andMinTracks:(int) minTracks andMaxAlbums: (int) maxAlbums
{
    if(allTracks == nil) return;
    
    int totalAlbumTracksAdded = 0;
    int albumsProcessed = 0;
    int totalSinglesTracksAdded = 0;
    
    NSMutableArray *singles = [allTracks objectForKey:SINGLES_CONTEXT]; 
    [self notify: [NSString stringWithFormat:@"original singles count: %lu", [singles count]]];
    NSDictionary *albums = [allTracks objectForKey:ALBUM_CONTEXT];
    long totalAlbums = [albums count];
    NSMutableArray *albumKeys = [[NSMutableArray alloc] init];
    [self notify: [NSString stringWithFormat:@"original album count: %lu", [albums count]]];
    
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
                totalAlbumTracksAdded += [self addSongs:album toPlayList:albumsPlaylist andIdentifier:@"there"];
                albumsProcessed++;
                if(albumsProcessed > maxAlbums){
                    break;
                }
            }
        }
    }

    // handle singles
    if(toPlaylistNameSingles != nil){
        [self notify: [NSString stringWithFormat:@"new singles count: %lu", [singles count]]];
        iTunesUserPlaylist *singlesPlaylist = [self getPlaylistWithName:toPlaylistNameSingles];
        if(singlesPlaylist != nil && singles != nil){
            totalSinglesTracksAdded += [self addSongs:singles toPlayList:singlesPlaylist andIdentifier:@"singles"];
        }
    }

    [self notify: [NSString stringWithFormat:@"%d albums (out of %ld total) added with %d songs to %@", albumsProcessed, totalAlbums, totalAlbumTracksAdded, toPlaylistNameAlbums]];
    [self notify: [NSString stringWithFormat:@"%d singles added to %@", totalSinglesTracksAdded, toPlaylistNameSingles]];
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

- (void) notify: (NSString *) message {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"output" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:message, @"output", nil]];
}
@end
