#ifndef MoneroTransferAdapter_h
#define MoneroTransferAdapter_h

@interface MoneroTransferAdapter : NSObject
@property (nonatomic, readonly) uint64_t amount;
@property (nonatomic, readonly) NSString *address;
- (instancetype)initWithAmount:(uint64_t) amount andAddress:(NSString *) address;
@end

#endif /* MoneroTransferAdapter_h */
