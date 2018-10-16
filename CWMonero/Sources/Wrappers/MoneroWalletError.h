#import <Foundation/Foundation.h>

#ifndef MoneroWalletError_h
#define MoneroWalletError_h

FOUNDATION_EXPORT NSString *const MoneroWalletErrorDomain;

enum {
    MoneroWalletCreatingError = 1000,
    MoneroWalletLoadingError,
    MoneroWalletRecoveringError,
    MoneroWalletSavingError,
    MoneroWalletConnectingError,
    MoneroWalletPasswordChangingError,
    MoneroWalletTransactionCreatingError
};

#endif /* MoneroWalletError_h */
