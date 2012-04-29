//
//  AGAppDelegate.m
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AGAppDelegate.h"

@implementation AGAppDelegate

@synthesize window = _window, agItunes,
minSongPopUp, toPlaylistPopUp, 
fromPlaylistPopUp, maxAlbumPopUp;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    int i = 0;
    self.agItunes = [[AGItunes alloc] init];    
    SBElementArray *availablePlaylists = [self.agItunes getItunesPlaylists];

    if(availablePlaylists != nil){
        for(iTunesPlaylist *playlist in availablePlaylists){
            [self.toPlaylistPopUp insertItemWithTitle:[playlist name] atIndex:i];
            [self.fromPlaylistPopUp insertItemWithTitle:[playlist name] atIndex:i];
            i++;
        }
    }
    
    for(i = 0; i<11; i++){
        NSString *is = [NSString stringWithFormat:@"%d", (i+2)];
        [self.maxAlbumPopUp insertItemWithTitle:is atIndex:i];
    }
    
    for(i = 0; i<9; i++){
        NSString *is = [NSString stringWithFormat:@"%d", (i+2)];
        [self.minSongPopUp insertItemWithTitle:is atIndex:i];
    }
    
    [self.maxAlbumPopUp selectItemAtIndex:8];
    [self.minSongPopUp selectItemAtIndex:3];
}

-(IBAction)arrangeTracks:(id)sender
{
    NSString *fromPlaylistName = [self.fromPlaylistPopUp titleOfSelectedItem];
    NSString *toPlaylistName = [self.toPlaylistPopUp titleOfSelectedItem];
    int minTracks = (int) [[self.minSongPopUp titleOfSelectedItem] doubleValue];
    int maxAlbums = (int) [[self.maxAlbumPopUp titleOfSelectedItem] doubleValue];
    if (![self validateFromPlaylist:fromPlaylistName andToName:toPlaylistName andMinSongs:minTracks andMaxAlbums:maxAlbums]) {
        // todo: message?
        return;
    }
                 
    NSDictionary *tracks = [self.agItunes getSongsFromPlaylist:fromPlaylistName];
    if(tracks == nil){
        // from playlist doesn't exist
    } else if([tracks count] == 0){
        // no tracks or tracks with no albums in the playlist
    } else {
    
        [self.agItunes createNewPlaylist:toPlaylistName FromDictionary:tracks andMinTracks:minTracks andMaxAlbums:maxAlbums];
    }
}

-(bool) validateFromPlaylist: (NSString *) fromName andToName: (NSString *) toName andMinSongs: (int) minSongs andMaxAlbums: (int) maxAlbums
{
    bool valid = true;
    if(fromName == nil || toName == nil || minSongs == 0 || maxAlbums == 0){
        NSLog(@"problems");
        valid = false;
    }
    return valid;
}

@end
