//
//  HBFocusUtils.h
//  TLStoryCameraFramework
//
//  Created by Federico Frappi on 22/03/2018.
//  Copyright © 2018 com.garry. All rights reserved.
//

#import <GPUImage/GPUImageFramework.h>

@interface HBFocusUtils : NSObject

+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                               inFrame:(CGRect)frame
                                       withOrientation:(UIDeviceOrientation)orientation
                                           andFillMode:(GPUImageFillModeType)fillMode
                                              mirrored:(BOOL)mirrored;

+ (void)setFocus:(CGPoint)focus forDevice:(AVCaptureDevice *)device;

@end
