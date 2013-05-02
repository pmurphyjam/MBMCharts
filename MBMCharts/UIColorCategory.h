//
//  UIColorCategory.h
//  InventoryManagement
//
//  Copyright 2011 Mobitor. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (ColorCategory)

+(UIColor*)colorWithHexRGB:(NSString*)hexRGB AndAlpha:(float)alpha;

@end
