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
NSString * const SOURCE_PLAYLIST = @"SOURCE";
NSString * const TO_ALBUM_PLAYLIST = @"TO_ALBUM";
NSString * const TO_SINGLE_PLAYLIST = @"TO_SINGLE";
NSString * const CLEAR_TO_SINGLE_PLAYLIST = @"TO_SINGLE_CLEAR";
NSString * const CLEAR_TO_ALBUM_PLAYLIST = @"TO_ALBUM_CLEAR";
NSString * const MAX_ALBUMS = @"MAX_ALBUMS";
NSString * const MIN_SONGS_PER_ALBUM = @"MIN_SONGS";

@synthesize window = _window, agItunes,
minSongPopUp, toPlaylistSinglesPopUp, toPlaylistAlbumsPopUp, 
fromPlaylistPopUp, maxAlbumPopUp, outputField,
clearAlbumsPlaylistButton, clearSinglesPlaylistButton;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:SETTINGS_KEY] == nil){
        NSDictionary *defaultSettings = [[NSDictionary alloc] initWithObjectsAndKeys:@"Music", SOURCE_PLAYLIST,
                                         NO_PLAYLIST, TO_ALBUM_PLAYLIST, NO_PLAYLIST, TO_SINGLE_PLAYLIST, @"5",
                                         MIN_SONGS_PER_ALBUM, @"10", MAX_ALBUMS, @"YES", CLEAR_TO_ALBUM_PLAYLIST, 
                                         @"YES", CLEAR_TO_SINGLE_PLAYLIST, nil];
        NSDictionary *domain = [[NSDictionary alloc] initWithObjectsAndKeys:defaultSettings, SETTINGS_KEY, nil];
        [defaults registerDefaults:domain];
        [defaults synchronize];
    }
    
    self.agItunes = [[AGItunes alloc] init];    
    [self populateForm];
    [self loadSettings];
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

-(NSString *) getPlayListName: (NSPopUpButton *) button
{
    NSString *name = [button titleOfSelectedItem];
    if([name length] == 0){
        name = nil;
    }
    return nil;
}

-(IBAction)arrangeTracks:(id)sender
{
    [self saveSettings];
    NSString *fromPlaylistName = [self.fromPlaylistPopUp titleOfSelectedItem];
    NSString *toPlaylistNameSingles = [self.toPlaylistSinglesPopUp titleOfSelectedItem];
    NSString *toPlaylistNameAlbums = [self.toPlaylistAlbumsPopUp titleOfSelectedItem];
    int minTracks = (int) [[self.minSongPopUp titleOfSelectedItem] doubleValue];
    int maxAlbums = (int) [[self.maxAlbumPopUp titleOfSelectedItem] doubleValue];
    bool doClearSinglesPlaylist = [self.clearSinglesPlaylistButton state] == NSOnState;
    bool doClearAlbumsPlaylist = [self.clearAlbumsPlaylistButton state] == NSOnState;

    if (![self validateFromPlaylist:fromPlaylistName andToSinglesName:toPlaylistNameSingles andToAlbumsName:toPlaylistNameAlbums andMinSongs:minTracks andMaxAlbums:maxAlbums]) {
        DLog(@"%@, %@, %@, %d, %d", fromPlaylistName, toPlaylistNameSingles, toPlaylistNameAlbums, minTracks, maxAlbums);
        return;
    }
                 
    NSDictionary *tracks = [self.agItunes getSongsFromPlaylist:fromPlaylistName];
    if(tracks == nil){
        // from playlist doesn't exist
        DLog(@"playlist %@ doesn't seem to exist", fromPlaylistName);
    } else if([tracks count] == 0){
        // no tracks or tracks with no albums in the playlist
        DLog(@"playlist %@ seems to be empty", fromPlaylistName);
    } else {
        if(doClearSinglesPlaylist && toPlaylistNameSingles != nil){
            [self.agItunes clearPlaylistWithName:toPlaylistNameSingles];
        }
        if(doClearAlbumsPlaylist && toPlaylistNameAlbums != nil){
            [self.agItunes clearPlaylistWithName:toPlaylistNameAlbums];            
        }
        [self.agItunes moveSinglesTo:toPlaylistNameSingles andAlbumsTo:toPlaylistNameAlbums FromDictionary:tracks andMinTracks:minTracks andMaxAlbums:maxAlbums];
        [[self.agItunes getItunes] activate];
    }
}

-(bool) validateFromPlaylist: (NSString *) fromName andToSinglesName: (NSString *) toSinglesName andToAlbumsName: (NSString *) toAlbumsName andMinSongs: (int) minSongs andMaxAlbums: (int) maxAlbums
{
    bool valid = true;
    if(fromName == NO_PLAYLIST || (toSinglesName ==  NO_PLAYLIST && toAlbumsName == NO_PLAYLIST) || minSongs == 0 || maxAlbums == 0){
        DLog(@"problems - invalid inputs");
        valid = false;
    }
    return valid;
}

-(void) saveSettings
{
    NSString *fromPlaylistName = [self.fromPlaylistPopUp titleOfSelectedItem];
    NSString *toPlaylistNameSingles = [self.toPlaylistSinglesPopUp titleOfSelectedItem];
    NSString *toPlaylistNameAlbums = [self.toPlaylistAlbumsPopUp titleOfSelectedItem];
    NSString *minTracks = [self.minSongPopUp titleOfSelectedItem];
    NSString *maxAlbums = [self.maxAlbumPopUp titleOfSelectedItem];
    NSString *doClearSinglesPlaylist = ([self.clearSinglesPlaylistButton state] == NSOnState) ? @"YES" : @"NO";
    NSString *doClearAlbumsPlaylist = ([self.clearAlbumsPlaylistButton state] == NSOnState) ? @"YES" : @"NO";

    NSMutableDictionary *formData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     fromPlaylistName,SOURCE_PLAYLIST, toPlaylistNameAlbums, TO_ALBUM_PLAYLIST,
                                     toPlaylistNameSingles, TO_SINGLE_PLAYLIST, minTracks, MIN_SONGS_PER_ALBUM, 
                                     maxAlbums, MAX_ALBUMS, doClearAlbumsPlaylist, CLEAR_TO_ALBUM_PLAYLIST, 
                                     doClearSinglesPlaylist, CLEAR_TO_SINGLE_PLAYLIST, nil];
    [[NSUserDefaults standardUserDefaults] setValue:formData forKey:SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)loadSettings
{
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY];
    DLog(@"settings %@", settings);
    if(settings != nil){
        NSString *fromPlaylistName = [settings objectForKey:SOURCE_PLAYLIST];
        NSString *toPlaylistNameSingles = [settings objectForKey:TO_SINGLE_PLAYLIST];
        NSString *toPlaylistNameAlbums = [settings objectForKey:TO_ALBUM_PLAYLIST];
        NSString *minTracks = [settings objectForKey:MIN_SONGS_PER_ALBUM];
        NSString *maxAlbums = [settings objectForKey: MAX_ALBUMS];
        bool doClearSinglesPlaylist = [settings objectForKey:CLEAR_TO_SINGLE_PLAYLIST];
        bool doClearAlbumsPlaylist = [settings objectForKey:CLEAR_TO_ALBUM_PLAYLIST];
    
        [self.fromPlaylistPopUp selectItemWithTitle:fromPlaylistName];
        [self.toPlaylistSinglesPopUp selectItemWithTitle:toPlaylistNameSingles];
        [self.toPlaylistAlbumsPopUp selectItemWithTitle:toPlaylistNameAlbums];
        [self.minSongPopUp selectItemWithTitle:minTracks];
        [self.maxAlbumPopUp selectItemWithTitle:maxAlbums];
        [self.minSongPopUp selectItemWithTitle:minTracks];
        [self.clearSinglesPlaylistButton setState:doClearSinglesPlaylist];
        [self.clearAlbumsPlaylistButton setState:doClearAlbumsPlaylist];
    }
}

-(void) log: (NSString *) logString
{
    DLog(@"%@", logString);
    [self.outputField setStringValue:logString];
}


@end
