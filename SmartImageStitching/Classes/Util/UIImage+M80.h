//
//  UIImage+M80.h
//  SmartImageStitching
//
//  Created by Mosquito1123 on 17/07/2019.
//  Copyright © 2019 Cranberry. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (M80)
- (UIImage *)m80_subImage:(CGRect)rect;

- (UIImage *)m80_rangedImage:(NSRange)range;

- (BOOL)m80_saveAsPngFile:(NSString *)path;

- (UIImage *)m80_gradientImage;
@end

NS_ASSUME_NONNULL_END
