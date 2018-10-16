#import <Foundation/Foundation.h>
#import "MoneroWalletHistoryAdapter.h"
#import "wallet/api/wallet.h"
#import "wallet/api/transaction_history.h"
#import "MoneroWalletAdapter.h"
#import "MoneroTransactionInfoAdapter.mm"
#import "MoneroWalletAdapter.mm"
#import "Subaddresses.mm"

@implementation MoneroWalletHistoryAdapter: NSObject
Monero::TransactionHistory *transactionHistory;

- (instancetype)initWithWallet: (MoneroWalletAdapter *) wallet
{
    self = [super init];
    if (self) {
        transactionHistory = [wallet rawHistory];
    }
    return self;
}

- (int)count
{
    return transactionHistory->count();
}

- (MoneroTransactionInfoAdapter *)transaction:(int) index
{
    Monero::TransactionInfo *_tx = transactionHistory->transaction(index);
    MoneroTransactionInfoMember *txMember = new MoneroTransactionInfoMember();
    txMember->tx = _tx;
    MoneroTransactionInfoAdapter *tx = [[MoneroTransactionInfoAdapter alloc] initWithMember: txMember];
    return tx;
}

- (NSArray<MoneroTransactionInfoAdapter *> *)getAll
{
    NSMutableArray<MoneroTransactionInfoAdapter *> *_arr = [[NSMutableArray alloc] init];
    vector<Monero::TransactionInfo *> txs = transactionHistory->getAll();
    
    for (auto &originalTx : txs) {
        if (originalTx == NULL)
        {
            continue;
        }
        
        MoneroTransactionInfoMember *txMember = new MoneroTransactionInfoMember();
        txMember->tx = originalTx;
        MoneroTransactionInfoAdapter *tx = [[MoneroTransactionInfoAdapter alloc] initWithMember: txMember];
        [_arr addObject: tx];
    }
    
    return _arr;
}

- (void)refresh
{
    transactionHistory->refresh();
}
@end

