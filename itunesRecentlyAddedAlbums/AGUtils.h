//
//  AGUtils.h
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGUtils : NSObject

extern NSString * const SETTINGS_KEY;
extern NSString * const NO_PLAYLIST;
extern NSString * const SOURCE_PLAYLIST;
extern NSString * const TO_ALBUM_PLAYLIST;
extern NSString * const TO_SINGLE_PLAYLIST;
extern NSString * const CLEAR_TO_SINGLE_PLAYLIST;
extern NSString * const CLEAR_TO_ALBUM_PLAYLIST;
extern NSString * const MAX_ALBUMS;
extern NSString * const MIN_SONGS_PER_ALBUM;


extern NSString * const NON_ALBUM_TITLE;
extern NSString * const ALBUM_CONTEXT;
extern NSString * const SINGLES_CONTEXT;

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif

+(NSString *) stripString: (NSString *) origString;

@end
