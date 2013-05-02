//
//  UIImageCategory.h
//  
//  Created by Pat Murphy on 12/13/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
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
