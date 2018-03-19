//
//  AppPeriodicTask.m
//  App Scheduler
//
//  Copyright © 2018 Zendrive. All rights reserved.
//

#import "AppPeriodicTask.h"

@interface AppPeriodicTask ()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic) NSTimeInterval currentPeriod;
@property (nonatomic, copy) TaskBlock block;
@property (nonatomic) dispatch_queue_t queue;

- (void)startTask;

@end

@implementation AppPeriodicTask

- (id)initWithBlock:(TaskBlock)block
  withPeriodSeconds:(NSTimeInterval)period
            onQueue:(dispatch_queue_t)queue
  afterDelaySeconds:(NSTimeInterval)delay {
    self = [super init];
    if (self) {
        _block = block;
        _currentPeriod = period;
        _queue = queue;
        _timer = [[self class] getDispatchTimerWithIntervel:period
                                                      delay:delay
                                                      queue:queue
                                                      block:block
                                                     self:self];
    }
    return self;
}

- (void)dealloc {
    [self cancel];
}

//----------------------------------------------------------------------------------------
#pragma mark - public scheduling helpers
//----------------------------------------------------------------------------------------

+ (AppPeriodicTask *)scheduleBlock:(TaskBlock)block
                 withPeriodSeconds:(NSTimeInterval)period
                           onQueue:(dispatch_queue_t)queue
                 afterDelaySeconds:(NSTimeInterval)delay {
    AppPeriodicTask *task = [[AppPeriodicTask alloc]
                             initWithBlock:block
                             withPeriodSeconds:period
                             onQueue:queue
                             afterDelaySeconds:delay];
    [task startTask];
    return task;
}

+ (AppPeriodicTask *)scheduleBlock:(TaskBlock)block
                           onQueue:(dispatch_queue_t)queue
                 afterDelaySeconds:(NSTimeInterval)delay {
    TaskBlock oneTimeBlock = ^void(AppPeriodicTask *task) {
        block(task);
        [task cancel];
    };
    AppPeriodicTask *task = [[AppPeriodicTask alloc]
                             initWithBlock:oneTimeBlock
                             withPeriodSeconds:INT_MAX
                             onQueue:queue
                             afterDelaySeconds:delay];
    [task startTask];
    return task;
}

//----------------------------------------------------------------------------------------
#pragma mark - private methods
//----------------------------------------------------------------------------------------

- (void)startTask {
    dispatch_resume(_timer);
}

- (NSTimeInterval)getPeriod {
    return self.currentPeriod;
}

- (void)updatePeriod:(NSTimeInterval)newPeriod {
    @synchronized(self) {
        if (self.currentPeriod == newPeriod) {
            return;
        }
        dispatch_source_cancel(self.timer);
        self.timer = [AppPeriodicTask getDispatchTimerWithIntervel:newPeriod
                                                             delay:0
                                                             queue:self.queue
                                                             block:self.block
                                                            self:self];
        dispatch_resume(self.timer);
        self.currentPeriod = newPeriod;
    }
}

- (void)cancel {
    @synchronized(self) {
        if (nil == _timer) {
            return;
        }
        dispatch_source_cancel(_timer);
        _timer = nil;
        _block = nil;
        _queue = nil;
    }
}

- (BOOL)isCancelled {
    @synchronized(self) {
        return nil == self.timer;
    }
}

# pragma mark - timer creator helpers

+ (dispatch_source_t) getDispatchTimerWithIntervel:(NSTimeInterval) interval
                                             delay:(NSTimeInterval) delay
                                             queue:(dispatch_queue_t) queue
                                             block:(TaskBlock) block
                                              self:(id) object {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer) {
        dispatch_source_set_timer(timer,
                                  dispatch_walltime(NULL, delay * NSEC_PER_SEC),
                                  interval * NSEC_PER_SEC,
                                  1 * NSEC_PER_SEC /* leeway */);
        AppPeriodicTask __weak *weakSelf = object;
        dispatch_source_set_event_handler(timer, ^{ block(weakSelf); });
    }
    return timer;
}

@end
