//
//  AGAppDelegate.m
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AGAppDelegate.h"

@implementation AGAppDelegate

NSString * const SETTINGS_KEY = @"settings";
NSString * const NO_PLAYLIST = @"No playlist";

@synthesize window = _window, agItunes,
minSongPopUp, toPlaylistSinglesPopUp, toPlaylistAlbumsPopUp, 
fromPlaylistPopUp, maxAlbumPopUp, outputField,
clearAlbumsPlaylistButton, clearSinglesPlaylistButton;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.agItunes = [[AGItunes alloc] init];    
    [self populateForm];
}

- (void) populateForm
{
    SBElementArray *availablePlaylists = [self.agItunes getItunesPlaylists];
    
    [self.toPlaylistSinglesPopUp insertItemWithTitle:NO_PLAYLIST atIndex:0];
    [self.toPlaylistAlbumsPopUp insertItemWithTitle:NO_PLAYLIST atIndex:0];
    [self.fromPlaylistPopUp insertItemWithTitle:NO_PLAYLIST atIndex:0];
    int i = 1, ix = 1;
    if(availablePlaylists != nil){
        for(iTunesUserPlaylist *playlist in availablePlaylists){
            if([playlist specialKind] == iTunesESpKNone && ![playlist smart]){
                [self.toPlaylistSinglesPopUp insertItemWithTitle:[playlist name] atIndex:i];
                [self.toPlaylistAlbumsPopUp insertItemWithTitle:[playlist name] atIndex:i];
                i++;
            }            
            
            [self.fromPlaylistPopUp insertItemWithTitle:[playlist name] atIndex:ix];
            ix++;
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
}

-(IBAction)arrangeTracks:(id)sender
{
    NSString *fromPlaylistName = [self.fromPlaylistPopUp titleOfSelectedItem];
    NSString *toPlaylistNameSingles = [self.toPlaylistSinglesPopUp titleOfSelectedItem];
    NSString *toPlaylistNameAlbums = [self.toPlaylistAlbumsPopUp titleOfSelectedItem];
    int minTracks = (int) [[self.minSongPopUp titleOfSelectedItem] doubleValue];
    int maxAlbums = (int) [[self.maxAlbumPopUp titleOfSelectedItem] doubleValue];
    bool doClearSinglesPlaylist = [self.clearSinglesPlaylistButton state] == NSOnState;
    bool doClearAlbumsPlaylist = [self.clearAlbumsPlaylistButton state] == NSOnState;

    if (![self validateFromPlaylist:fromPlaylistName andToSinglesName:toPlaylistNameSingles andToAlbumsName:toPlaylistNameAlbums andMinSongs:minTracks andMaxAlbums:maxAlbums]) {
        // todo: message?
        return;
    }
                 
    NSDictionary *tracks = [self.agItunes getSongsFromPlaylist:fromPlaylistName];
    if(tracks == nil){
        // from playlist doesn't exist
    } else if([tracks count] == 0){
        // no tracks or tracks with no albums in the playlist
    } else {
        if(doClearSinglesPlaylist && toPlaylistNameSingles != nil){
            [self.agItunes clearPlaylistWithName:toPlaylistNameSingles];
        }
        if(doClearAlbumsPlaylist && toPlaylistNameAlbums != nil){
            [self.agItunes clearPlaylistWithName:toPlaylistNameAlbums];            
        }
        [self.agItunes moveSinglesTo:toPlaylistNameSingles andAlbumsTo:toPlaylistNameAlbums FromDictionary:tracks andMinTracks:minTracks andMaxAlbums:maxAlbums];
    }
}

-(bool) validateFromPlaylist: (NSString *) fromName andToSinglesName: (NSString *) toSinglesName andToAlbumsName: (NSString *) toAlbumsName andMinSongs: (int) minSongs andMaxAlbums: (int) maxAlbums
{
    bool valid = true;
    if(fromName == NO_PLAYLIST || (toSinglesName ==  NO_PLAYLIST && toAlbumsName == NO_PLAYLIST) || minSongs == 0 || maxAlbums == 0){
        NSLog(@"problems");
        valid = false;
    }
    return valid;
}

@end
