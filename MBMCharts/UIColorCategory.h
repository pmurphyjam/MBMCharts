//
//  UIColorCategory.h
//
//  Created by Pat Murphy on 12/13/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (ColorCategory)

+(UIColor*)colorWithHexRGB:(NSString*)hexRGB AndAlpha:(float)alpha;

@end
