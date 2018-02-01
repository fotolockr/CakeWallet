//
//  MoneroAmountParser.h
//  Wallet
//
//  Created by FotoLockr on 11/26/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef MoneroAmountParser_h
#define MoneroAmountParser_h

@interface MoneroAmountParser: NSObject
@property (nonatomic) uint64_t value;
+ (NSString *) formatValue: (uint64_t) value;
+ (uint64_t) amountFromString: (NSString *) str;
@end


#endif /* MoneroAmountParser_h */
