//
//  Nitrogen.h
//  Nitrogen
//
//  Created by Drew Crawford on 6/10/15.
//  Copyright © 2015 DrewCrawfordApps. All rights reserved.
//

#import "TargetConditionals.h"
#ifdef TARGET_OS_IOS
#import <Foundation/Foundation.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import <Nitrogen/fcntl_.h>
//! Project version number for Nitrogen.
FOUNDATION_EXPORT double NitrogenVersionNumber;

//! Project version string for Nitrogen.
FOUNDATION_EXPORT const unsigned char NitrogenVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Nitrogen/PublicHeader.h>
