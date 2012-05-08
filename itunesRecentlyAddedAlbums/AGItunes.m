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

NSString * const NON_ALBUM_TITLE = @"__NO_WAY_AN_ALBUM_WILL_BE_NAMED_THIS";

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

- (iTunesUserPlaylist *) getPlaylistWithName: (NSString *) playlistName
{
    SBElementArray *playlists = [self getItunesPlaylists];
    return [playlists objectWithName:playlistName];
}

- (NSDictionary *) getSongsFromPlaylist: (NSString *) fromPlaylistName
{
    iTunesUserPlaylist *playlist = [self getPlaylistWithName:fromPlaylistName];
    if(playlist == nil) return nil;
    
    SBElementArray *tracks = [playlist tracks];
    NSMutableDictionary *albums = [[NSMutableDictionary alloc] init];
    int trackCount = 0;
    int MAX_TRACKS = 1000;
    
    for(iTunesTrack *track in tracks){
        if(trackCount > MAX_TRACKS){
            break;
        }
        
        NSString *albumTitle = [AGUtils stripString:[track album]]; 
        if(albumTitle == nil || [albumTitle length] == 0){
            albumTitle = NON_ALBUM_TITLE;
        }

        NSInteger trackId = [track trackNumber];
        NSString *trackKey = (trackId == 0) ? [track name] : [NSString stringWithFormat:@"%ld", trackId];
        
        if(trackKey == nil || [trackKey length] == 0 || [self albumTitleIsBad: albumTitle]){
            DLog(@"SKIPPING: %@", [track name]);
            continue;
        }
        
        NSMutableDictionary *currAlbum = [albums objectForKey:albumTitle];
        if(currAlbum == nil){
            currAlbum = [[NSMutableDictionary alloc] init];
        }
        [currAlbum setValue:track forKey:trackKey];
        [albums setValue:currAlbum forKey:albumTitle];
        trackCount++;
    }
    DLog(@"%d total tracks added", trackCount);
    return albums;
}

-(void) clearPlaylistWithName: (NSString *) playlistName
{
    iTunesUserPlaylist *playlist = [self getPlaylistWithName:playlistName];
    if(playlist != nil){
        [self clearPlaylist:playlist];
    }
}

- (void) clearPlaylist: (iTunesPlaylist *) playlist
{
    SBElementArray *tracks = [playlist tracks];
    int trackCount = [tracks count];

    int deletedCount =0;
    // have to delete backwards because they shift up
    for(int i = trackCount; i>=0; i--){
        iTunesTrack *track = [tracks objectAtIndex:i];
        //DLog(@"deleting %@", [track name]);
        [track delete];
        deletedCount++;
    }  
    DLog(@"%d tracks deleted", deletedCount);
}

- (void) moveSinglesTo: (NSString *) toPlaylistNameSingles andAlbumsTo: (NSString *)toPlaylistNameAlbums FromDictionary: (NSMutableDictionary *)albums andMinTracks:(int) minTracks andMaxAlbums: (int) maxAlbums
{
    if(albums == nil) return;
    
    iTunesUserPlaylist *singlesPlaylist = nil;
    if(toPlaylistNameSingles != nil){
        singlesPlaylist = [self getPlaylistWithName:toPlaylistNameSingles];
    }
    NSDictionary *singles = [albums objectForKey:NON_ALBUM_TITLE]; 
    DLog(@"original singles count: %lu", [singles count]);
    [albums removeObjectForKey:NON_ALBUM_TITLE];
    
    // handle albums
    int albumTrackCount = 0;
    int albumCount = 0;
    int singlesCount = 0;
    int totalAlbums = [albums count];
    if(toPlaylistNameAlbums != nil){
        iTunesUserPlaylist *albumsPlaylist = [self getPlaylistWithName:toPlaylistNameAlbums];
        if(albumsPlaylist != nil){
            for(NSString *albumTitle in albums){
                if(albumCount > maxAlbums){
                    break;
                }

                NSDictionary *albumTracks = [albums objectForKey:albumTitle];
                int currentAlbumTrackCount = [albumTracks count];
                DLog(@"Working on album: %@", albumTitle);                
                
                if(currentAlbumTrackCount >= minTracks){
                    //DLog(@"skipping album: %@ for having %lu songs when %d are required", albumTitle, [albumTracks count], minTracks);
                    //[singles addEntriesFromDictionary:albumTracks];
                    albumTrackCount += [self addSongs:albumTracks toPlayList:albumsPlaylist andIdentifier:@"there"];
                    albumCount++;
                } else if(singlesPlaylist != nil){
                    singlesCount += [self addSongs:albumTracks toPlayList:singlesPlaylist andIdentifier:@"here"];
                }   
            }
        }
    }
    DLog(@"%d albums (out of %d total) added with %d songs to %@", albumCount, totalAlbums, albumTrackCount, toPlaylistNameAlbums);
    
    // handle singles
    DLog(@"new singles count: %lu", [singles count]);
    if(singlesPlaylist != nil && singles != nil){
        singlesCount += [self addSongs:singles toPlayList:singlesPlaylist andIdentifier:@"singles"];
    }
    DLog(@"%d singles added to %@", singlesCount, toPlaylistNameSingles);
}

- (int) addSongs: (NSDictionary *) albumTracks toPlayList: (iTunesPlaylist *) playlist andIdentifier: (NSString *) ident
{
    int count = 0;
    NSArray *trackKeys = [albumTracks allKeys];
    NSArray *keys = [trackKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return obj1 > obj2;
    }];
    
    for(NSString *key in keys){
        iTunesTrack *track = [albumTracks objectForKey:key];
        if([[track name] isEqualToString:@"Go Now"] || [[track name] isEqualToString:@"I'm About Cream"]){
            NSLog(@"WTF! %@ %@", [track name], track);
        }
        SBObject *result = [track duplicateTo:playlist];
        DLog(@"%@ %@ %@", ident, [track name], result);
        count++;
    }
    return count;
}
@end
