In Objective-C, a tricky bug can arise from the interaction between KVO (Key-Value Observing) and memory management. If an observer is not removed properly before the observed object is deallocated, it can lead to crashes or unexpected behavior.  For example:

```objectivec
@interface MyObject : NSObject
@property (nonatomic, strong) NSString *observedString;
@end

@implementation MyObject
- (void)dealloc {
    NSLog(@"MyObject deallocating");
}
@end

@interface MyObserver : NSObject
@end

@implementation MyObserver
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"Observed value changed!");
}

- (void)dealloc {
    NSLog(@"MyObserver deallocating");
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MyObject *myObject = [[MyObject alloc] init];
        MyObserver *myObserver = [[MyObserver alloc] init];
        [myObject addObserver:myObserver forKeyPath:@"observedString" options:NSKeyValueObservingOptionNew context:NULL];
        myObject.observedString = @"Hello";
        myObject = nil; //This is where the problem occurs if the observer isn't removed
    }
    return 0;
}
```

In this scenario, if `myObserver` doesn't remove itself as an observer before `myObject` is deallocated,  it may try to access deallocated memory, leading to a crash.