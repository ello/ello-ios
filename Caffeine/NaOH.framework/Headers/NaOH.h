//
//  NaOH.h
//  NaOH
//
//  Created by Drew Crawford on 8/16/15.
//  Copyright © 2015 Drew Crawford. All rights reserved.
//  This file is part of NaOH.  It is subject to the license terms in the LICENSE
//  file found inthe top level of this distribution
//  No part of NaOH, including this file, may be copied, modified,
//  propagated, or distributed except according to the terms contained
//  inthe LICENSE file.
#import "TargetConditionals.h"
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for NaOH.
FOUNDATION_EXPORT double NaOHVersionNumber;

//! Project version string for NaOH.
FOUNDATION_EXPORT const unsigned char NaOHVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NaOH/PublicHeader.h>

#import "sodium.h"


