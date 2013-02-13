//
//  UIImageCategory.h
//  MBMClient
//
//  Created by Anantha Srinivas Malyala on 12/21/11.
//  Copyright (c) 2011 Mobitor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (ImageCategory)

+(UIImage*) imageWithName:(NSString *)imageName;
+(UIImage*) imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+(UIImage*) changeColor:(UIImage *)image toColor:(UIColor *)color;
+(UIImage*) scaleImage:(UIImage *)image toSize:(CGSize)size;
+(UIImage*) scaleCameraImage:(UIImage *)image toSize:(CGSize)size;
+(UIImage*) toGrayscale:(UIImage*)inImage;

@end
