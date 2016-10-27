//  Created by Jason Morrissey

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(long)hexColor;

+ (UIColor *)colorWithHex:(long)hexColor alpha:(CGFloat)opacity;

+ (UIColor *)getColorWithQulityLevel:(int)qulityLevel;

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

@end
