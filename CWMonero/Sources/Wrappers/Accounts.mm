#import <Foundation/Foundation.h>
#import "Accounts.h"
#import "Account.h"
#import "MoneroWalletAdapter.mm"
#import "wallet/api/subaddress_account.h"

struct AccountsMember {
    Monero::SubaddressAccountImpl *account;
};

@implementation Accounts: NSObject
- (instancetype)initWithWallet:(MoneroWalletAdapter *) wallet
{
    self = [super init];
    if (self) {
        member = new AccountsMember();
        member->account = new Monero::SubaddressAccountImpl(wallet->member->wallet);
    }
    return self;
}
    
- (void)newAccountWithLabel:(NSString *) label
{
    std::string utf8Label = [label UTF8String];
    member->account->addRow(utf8Label);
}
    
- (void)setLabel:(NSString *)label AtIndex:(uint32_t)index
{
    std::string utf8Label = [label UTF8String];
    member->account->setLabel(index, utf8Label);
}
    
- (NSArray *)getAll
{
    std::vector<Monero::SubaddressAccountRow*> accountRows = member->account->getAll();
    std::size_t count = accountRows.capacity();
    NSMutableArray *accounts = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < count; i++) {
        Monero::SubaddressAccountRow *accountRow =accountRows[i];
        NSString *label = [NSString stringWithUTF8String: accountRow->getLabel().c_str()];
        std::size_t index = accountRow->getRowId();
        Account *account = [[Account alloc] initWithLabel: label
                                                    index: static_cast<uint32_t>(index)];
        [accounts addObject:account];
    }
    
    return accounts;
}

- (void)refresh
{
    member->account->refresh();
}

@end
