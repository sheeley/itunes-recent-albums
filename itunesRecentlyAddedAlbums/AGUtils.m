//
//  AGUtils.m
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AGUtils.h"

@implementation AGUtils


NSString * const SETTINGS_KEY = @"settings";
NSString * const NO_PLAYLIST = @"No playlist";
NSString * const SOURCE_PLAYLIST = @"SOURCE";
NSString * const TO_ALBUM_PLAYLIST = @"TO_ALBUM";
NSString * const TO_SINGLE_PLAYLIST = @"TO_SINGLE";
NSString * const CLEAR_TO_SINGLE_PLAYLIST = @"TO_SINGLE_CLEAR";
NSString * const CLEAR_TO_ALBUM_PLAYLIST = @"TO_ALBUM_CLEAR";
NSString * const MAX_ALBUMS = @"MAX_ALBUMS";
NSString * const MIN_SONGS_PER_ALBUM = @"MIN_SONGS";

NSString * const NON_ALBUM_TITLE = @"__NO_WAY_AN_ALBUM_WILL_BE_NAMED_THIS";
NSString * const ALBUM_CONTEXT = @"ALBUM";
NSString * const SINGLES_CONTEXT = @"SINGLES";


+(NSString *) stripString: (NSString *) origString;
{
    return [origString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
