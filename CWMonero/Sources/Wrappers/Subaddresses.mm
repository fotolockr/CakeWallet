#import <Foundation/Foundation.h>
#import "Subaddresses.h"
#import "Subaddress.h"
#import "MoneroWalletAdapter.mm"
#import "wallet/api/subaddress.h"

uint32_t DEFAULT_ACCOUNT_INDEX = 0;

struct SubaddressesMember {
    Monero::SubaddressImpl *subaddressAccount;
};

@implementation Subaddresses: NSObject

- (instancetype)initWithWallet: (MoneroWalletAdapter *) wallet
{
    self = [super init];
    if (self) {
        member = new SubaddressesMember();
        member->subaddressAccount = new Monero::SubaddressImpl(wallet->member->wallet);
    }
    return self;
}

- (void)newSubaddressWithLabel:(NSString *) label withAccountIndex:(uint32_t) accountIndex
{
    string utf8Label = [label UTF8String];
    member->subaddressAccount->addRow(accountIndex, utf8Label);
}

- (void)setLabel:(NSString *)label AtIndex:(uint32_t)index withAccountIndex:(uint32_t) accountIndex
{
    string utf8Label = [label UTF8String];
    member->subaddressAccount->setLabel(accountIndex, index, utf8Label);
}

- (NSArray *)getAll
{
    std::vector<Monero::SubaddressRow*> _subs = member->subaddressAccount->getAll();
    std::size_t count = _subs.capacity();
    NSMutableArray *result = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < count; i++) {
        Monero::SubaddressRow *_sub =_subs[i];
        NSString *address = [NSString stringWithUTF8String: _sub->getAddress().c_str()];
        NSString *label = [NSString stringWithUTF8String: _sub->getLabel().c_str()];
        std::size_t index = _sub->getRowId();
        Subaddress *sub = [[Subaddress alloc] initWithAddress: address
                                                     andLabel: label
                                                        index: static_cast<uint32_t>(index)];
        [result addObject:sub];
    }
    
    return result;
}

- (void)refresh:(uint32_t) accountIndex
{
    member->subaddressAccount->refresh(accountIndex);
}

@end
