#import <Foundation/Foundation.h>
#import "MoneroTransactionInfoAdapter.h"
#import "wallet/api/wallet.h"
#import "MoneroTransferAdapter.mm"

struct MoneroTransactionInfoMember {
    Monero::TransactionInfo *tx;
};

@implementation MoneroTransactionInfoAdapter: NSObject

- (id)initWithMember: (MoneroTransactionInfoMember *) _member
{
    self = [super init];
    if (self) {
        member = _member;
    }
    
    return self;
}

- (int) direction
{
    return member->tx->direction();
}

- (BOOL) isPending
{
    return member->tx->isPending();
}

- (BOOL) isFailed
{
    return member->tx->isFailed();
}

- (uint64_t) amount
{
    return member->tx->amount();
}

- (uint64_t) fee
{
    return member->tx->fee();
}

- (uint64_t) blockHeight
{
    return member->tx->blockHeight();
}

- (uint64_t) confirmations
{
    return member->tx->confirmations();
}

- (NSString *) paymentId
{
    return [NSString stringWithUTF8String: member->tx->paymentId().c_str()];
}
    
- (uint32_t)subaddrAccount
{
    return member->tx->subaddrAccount();
}

- (NSArray<NSNumber *> *)subaddrIndex
{
    std::set<uint32_t> subaddrIndex = member->tx->subaddrIndex();
    NSMutableArray *res = [NSMutableArray arrayWithCapacity: subaddrIndex.size()];
    
    for(uint32_t i : subaddrIndex) {
        NSNumber *num = [NSNumber numberWithUnsignedChar: i];
        [res addObject: num];
    }
    
    return res;
}

- (NSTimeInterval) timestamp
{
    if (member->tx != NULL) {
        return member->tx->timestamp();
    }
    
    return 0;
}

- (NSString *) printedAmount
{
    return [NSString stringWithUTF8String: cryptonote::print_money(member->tx->amount()).c_str()];
}

- (NSString *) note
{
    // FIX ME: NOT IMPLEMENTED
    return @"";
}

- (NSString *) hash
{
    return [NSString stringWithUTF8String: member->tx->hash().c_str()];
}

@end



