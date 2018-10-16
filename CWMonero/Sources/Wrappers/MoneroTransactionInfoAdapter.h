#import "MoneroWalletAdapter.h"

#ifndef MoneroTransactionInfoAdapter_h
#define MoneroTransactionInfoAdapter_h

struct MoneroTransactionInfoMember;


@interface MoneroTransactionInfoAdapter: NSObject
{
    struct MoneroTransactionInfoMember *member;
}
- (int) direction;
- (BOOL) isPending;
- (BOOL) isFailed;
- (uint64_t) amount;
- (uint64_t) fee;
- (uint64_t) blockHeight;
- (uint64_t) confirmations;
- (NSString *) paymentId;
- (NSTimeInterval) timestamp;
- (NSString *) printedAmount;
- (NSString *) note;
- (NSString *) hash;
@end

#endif /* MoneroTransactionInfoAdapter_h */
