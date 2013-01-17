//
//  UIImageCategory.m
//  MBMClient
//
//  Created by Anantha Srinivas Malyala on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageCategory.h"

@implementation UIImage (Category)

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

static inline double radians (double degrees) {return degrees * M_PI/180;}

+(UIImage*)imageWithName:(NSString *)imageName
{
    NSString *imageWithPath = [NSString stringWithFormat:@"/Images/%@",imageName]; 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *temp = [paths objectAtIndex:0];    
	UIImage *image = [UIImage imageWithContentsOfFile:[temp stringByAppendingPathComponent:imageWithPath]];
    if(image == nil)
    {
        image = [UIImage imageNamed:imageName];
    }
    return  image;
}

+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage*)scaleImage:(UIImage *)image toSize:(CGSize)size
{
	return [UIImage imageWithImage:image scaledToSize:size];
}

+(UIImage*)changeColor:(UIImage *)image toColor:(UIColor *)fillColor
{
    UIGraphicsBeginImageContext(image.size);
	CGRect contextRect;
	contextRect.origin.x = 0.0f;
	contextRect.origin.y = 0.0f;
	contextRect.size = [image size];
	CGSize itemImageSize = [image size];
	CGPoint itemImagePosition; 
	itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
	itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) );
	UIGraphicsBeginImageContext(contextRect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextBeginTransparencyLayer(context, NULL);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextClipToMask(context, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height), [image CGImage]);
	CGContextSetFillColorWithColor(context, [fillColor CGColor]);
	contextRect.size.height = -contextRect.size.height;
	contextRect.size.height -= 15;
	CGContextFillRect(context, contextRect);
	CGContextEndTransparencyLayer(context);
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
}



+(UIImage*)scaleCameraImage:(UIImage *)image toSize:(CGSize)size {
	//Used for scalling and rotating images from UIImagePicker camera
    UIImage* sourceImage = image; 
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }       
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGInterpolationQuality quality = kCGInterpolationLow;
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
}


CGImageRef grayscaleCGImageFromCGImage(CGImageRef inputImage) {
    size_t width = CGImageGetWidth(inputImage);
    size_t height = CGImageGetHeight(inputImage);
    
    // Create a gray scale context and render the input image into that
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8,
                                                 4*width, colorspace, kCGBitmapByteOrderDefault);
    CGContextDrawImage(context, CGRectMake(0,0, width,height), inputImage);
    
    // Get an image representation of the grayscale context which the input
    //    was rendered into.
    CGImageRef outputImage = CGBitmapContextCreateImage(context);
    
    // Cleanup
    CGContextRelease(context);
    CGColorSpaceRelease(colorspace);
    return (CGImageRef)[(id)outputImage autorelease];
}


+(UIImage *) toGrayscale:(UIImage*)inImage
{
    CGImageRef cgImageRef = [inImage CGImage];
    CGImageRef grayImageRef = grayscaleCGImageFromCGImage(cgImageRef);
    return [UIImage imageWithCGImage:grayImageRef];
}


@end
