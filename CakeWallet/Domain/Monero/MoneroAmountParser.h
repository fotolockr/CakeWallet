//
//  MoneroAmountParser.h
//  Wallet
//
//  Created by Cake Technologies 11/26/17.
//  Copyright © 2017 Cake Technologies. 
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
