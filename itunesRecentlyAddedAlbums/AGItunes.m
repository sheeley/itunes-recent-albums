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
            DLog(@"Hit %d tracks, done reading", MAX_TRACKS);
            break;
        }
        
        NSString *albumTitle = [AGUtils stripString:[track album]]; 
        if(albumTitle == nil || [albumTitle length] == 0){
            albumTitle = NON_ALBUM_TITLE;
        }
        
        if(([track trackNumber] == 0 && [[track name] length] == 0) || [self albumTitleIsBad: albumTitle]){
            DLog(@"SKIPPING: %@", [track name]);
            continue;
        }
        
        NSMutableArray *currAlbum = [albums objectForKey:albumTitle];
        if(currAlbum == nil){
            currAlbum = [[NSMutableArray alloc] init];
        }
        [currAlbum addObject:track];
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
        [track delete];
        deletedCount++;
    }  
    DLog(@"%d tracks deleted", deletedCount);
}

- (void) moveSinglesTo: (NSString *) toPlaylistNameSingles andAlbumsTo: (NSString *)toPlaylistNameAlbums FromDictionary: (NSMutableDictionary *)albums andMinTracks:(int) minTracks andMaxAlbums: (int) maxAlbums
{
    if(albums == nil) return;
    
    NSMutableArray *singles = [albums objectForKey:NON_ALBUM_TITLE]; 
    DLog(@"original singles count: %lu", [singles count]);
    [albums removeObjectForKey:NON_ALBUM_TITLE];
    
    // handle albums
    int albumTrackCount = 0;
    int albumCount = 0;
    int singlesCount = 0;
    int totalAlbums = [albums count];
    bool skipAlbums = false;
    if(toPlaylistNameAlbums != nil){
        iTunesUserPlaylist *albumsPlaylist = [self getPlaylistWithName:toPlaylistNameAlbums];
        if(albumsPlaylist != nil){
            for(NSString *albumTitle in albums){
                if(albumCount > maxAlbums){
                    skipAlbums = YES;
                }

                NSArray *album = [albums objectForKey:albumTitle];
                int currentAlbumTrackCount = [album count];
                //DLog(@"Working on album: %@", albumTitle);                
                
                if(!skipAlbums && currentAlbumTrackCount >= minTracks){
                    //DLog(@"skipping album: %@ for having %lu songs when %d are required", albumTitle, [albumTracks count], minTracks);
                    albumTrackCount += [self addSongs:album toPlayList:albumsPlaylist andIdentifier:@"there"];
                    albumCount++;
                } else {
                    //singlesCount += [self addSongs:albumTracks toPlayList:singlesPlaylist andIdentifier:@"here"];
                    [singles addObjectsFromArray:album];
                }   
            }
        }
    }
    
    iTunesUserPlaylist *singlesPlaylist = nil;
    if(toPlaylistNameSingles != nil){
        singlesPlaylist = [self getPlaylistWithName:toPlaylistNameSingles];
    }
    
    // handle singles
    DLog(@"new singles count: %lu", [singles count]);
    if(singlesPlaylist != nil && singles != nil){
        singlesCount += [self addSongs:singles toPlayList:singlesPlaylist andIdentifier:@"singles"];
    }
    DLog(@"\n%d albums (out of %d total) added with %d songs to %@", albumCount, totalAlbums, albumTrackCount, toPlaylistNameAlbums);
    DLog(@"%d singles added to %@", singlesCount, toPlaylistNameSingles);
}

- (int) addSongs: (NSArray *) albumTracks toPlayList: (iTunesPlaylist *) playlist andIdentifier: (NSString *) ident
{
    int count = 0;
    if([ident isEqualToString:@"singles"]){
        albumTracks = [albumTracks sortedArrayUsingComparator:^NSComparisonResult(iTunesTrack *t1, iTunesTrack *t2) {
            return [t1 dateAdded] > [t2 dateAdded];
        }];
    } else {
        albumTracks = [albumTracks sortedArrayUsingComparator:^NSComparisonResult(iTunesTrack *t1, iTunesTrack *t2) {
            NSString *t1c = ([t1 trackNumber] != 0) ? [NSString stringWithFormat:@"%d",[t1 trackNumber]] : [t1 name];
            NSString *t2c = ([t2 trackNumber] != 0) ? [NSString stringWithFormat:@"%d",[t2 trackNumber] ]: [t2 name];
            return t1c > t2c;
        }];
    }
    
    for(iTunesTrack *track in albumTracks){
        [track duplicateTo:playlist];
        count++;
    }
    return count;
}
@end
