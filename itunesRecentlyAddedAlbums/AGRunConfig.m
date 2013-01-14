//
//  AGRunConfig.m
//  itunesRecentlyAddedAlbums
//
//  Created by Sheeley, John(jsheeley) on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AGRunConfig.h"

@implementation AGRunConfig

-(id)initWith
{
    if (self = [super init])
    {
        self.maxTracksToIngest = 1000;   
    }
    return self;
}

@end
