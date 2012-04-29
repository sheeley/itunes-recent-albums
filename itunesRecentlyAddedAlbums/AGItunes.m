//
//  AGItunes.m
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AGItunes.h"

@implementation AGItunes


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
    //[iTunes activate];
    
    SBElementArray *sources = [iTunes sources];
    iTunesSource *source;
    for(source in sources){
        if([[source name] isEqualToString:@"Library"]){
            break;
        }
    }
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

- (iTunesPlaylist *) getPlaylistWithName: (NSString *) playlistName
{
    SBElementArray *playlists = [self getItunesPlaylists];
    if(playlists != nil){
        for(iTunesPlaylist *playlist in playlists){
            if([[playlist name] isEqualToString:playlistName]){
                return playlist;
            }
        }
    }
    return nil;
}

- (NSDictionary *) getSongsFromPlaylist: (NSString *) fromPlaylistName
{
    iTunesPlaylist *playlist = [self getPlaylistWithName:fromPlaylistName];
    if(playlist == nil) return nil;
    
    SBElementArray *tracks = [playlist tracks];
    NSMutableDictionary *albums = [[NSMutableDictionary alloc] init];
    
    for(iTunesTrack *track in tracks){
        NSString *albumTitle = [track album];
        if(albumTitle == nil || [[albumTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0){
            continue;
        }
        NSInteger trackId = [track trackNumber];
        NSString *trackName = [track name];
        NSString *trackKey = (trackId != 0) ? [NSString stringWithFormat:@"%@", trackId] : trackName;
        
        if(trackKey == nil || [trackKey length] == 0 || [self albumTitleIsBad: albumTitle]) continue;
        
        NSMutableDictionary *currAlbum = [albums objectForKey:albumTitle];
        if(currAlbum == nil){
            currAlbum = [[NSMutableDictionary alloc] init];
        }
        [currAlbum setValue:track forKey:trackKey];
        [albums setValue:currAlbum forKey:albumTitle];
    }
    return albums;
}

- (void) clearPlaylist: (iTunesPlaylist *) playlist
{
    SBElementArray *tracks = [playlist tracks];
    for(iTunesTrack *track in tracks){
        [track delete];
    }
    
}

- (void) createNewPlaylist: (NSString *) toPlaylistName FromDictionary: (NSDictionary *) albums andMinTracks: (NSInteger) minTracks andMaxAlbums: (int)maxAlbums
{
    iTunesPlaylist *playlist = [self getPlaylistWithName:toPlaylistName];
    if(playlist == nil) return;
    
    if([[playlist tracks] count] > 0){
        [self clearPlaylist:playlist];
    }
    
    __block int albumCount = 0;
    [albums enumerateKeysAndObjectsUsingBlock:^(NSString *albumTitle, NSDictionary *albumTracks, BOOL *stop) {
        if([albumTracks count] >= minTracks){
            if(albumCount > maxAlbums){
                return;
            }
            albumCount++;
            // sort tracks?
            NSArray *trackKeys = [albumTracks allKeys];
            NSArray *keys = [trackKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return obj1 > obj2;
            }];
            
            for(NSString *key in keys){
                [[albumTracks objectForKey:key] duplicateTo:playlist];
            }
/*
            [albumTracks enumerateKeysAndObjectsUsingBlock:^(id key, iTunesTrack *track, BOOL *stop) {
                //[tracks insertObject:track atIndex:[tracks count]]; 
                [track duplicateTo:playlist];
            }];*/
        }
    }];
}
@end
