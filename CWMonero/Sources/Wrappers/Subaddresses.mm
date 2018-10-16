#import <Foundation/Foundation.h>
#import "Subaddresses.h"
#import "Subaddress.h"
#import "MoneroWalletAdapter.mm"
#import "wallet/api/subaddress.h"

uint32_t DEFAULT_ACCOUNT_INDEX = 0;

@implementation Subaddresses: NSObject
Monero::SubaddressImpl *subaddressAccount;

- (instancetype)initWithWallet: (MoneroWalletAdapter *) wallet
{
    self = [super init];
    if (self) {
        subaddressAccount = new Monero::SubaddressImpl(wallet->member->wallet);
    }
    return self;
}

- (void)newSubaddressWithLabel:(NSString *) label
{
    string utf8Label = [label UTF8String];
    subaddressAccount->addRow(DEFAULT_ACCOUNT_INDEX, utf8Label);
}

- (void)setLabel:(NSString *)label AtIndex:(uint32_t)index
{
    string utf8Label = [label UTF8String];
    subaddressAccount->setLabel(DEFAULT_ACCOUNT_INDEX, index, utf8Label);
}

- (NSArray *)getAll
{
    std::vector<Monero::SubaddressRow*> _subs = subaddressAccount->getAll();
    std::size_t count = _subs.capacity();
    NSMutableArray *result = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < count; i++) {
        Monero::SubaddressRow *_sub =_subs[i];
        NSString *address = [NSString stringWithUTF8String: _sub->getAddress().c_str()];
        NSString *label = [NSString stringWithUTF8String: _sub->getLabel().c_str()];
        Subaddress *sub = [[Subaddress alloc] initWithAddress: address
                                                     andLabel: label];
        [result addObject:sub];
    }
    
    return result;
}

- (void)refresh
{
    subaddressAccount->refresh(DEFAULT_ACCOUNT_INDEX);
}

@end
