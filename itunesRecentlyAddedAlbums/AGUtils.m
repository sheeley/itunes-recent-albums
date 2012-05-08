//
//  AGUtils.m
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AGUtils.h"

@implementation AGUtils



+(NSString *) stripString: (NSString *) origString;
{
    return [origString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
