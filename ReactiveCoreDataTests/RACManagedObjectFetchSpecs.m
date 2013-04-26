//
//  RACManagedObjectFetchSpecs.m
//  ReactiveCoreData
//
//  Created by Jacob Gorban on 25/04/2013.
//  Copyright (c) 2013 Apparent Software. All rights reserved.
//

#import <Specta.h>
#define EXP_SHORTHAND
#import <Expecta.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSManagedObject+RACFetch.h"
#import "NSManagedObjectContext+ReactiveCoreData.h"
#import "Parent.h"

NSManagedObjectContext * contextForTest()
{
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    NSError *error = nil;
    NSPersistentStore *persistentStore = [psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
    if (!persistentStore) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [ctx setPersistentStoreCoordinator:psc];
    [ctx setUndoManager:nil];
    [NSManagedObjectContext setMainContext:ctx];
    return ctx;
}

SpecBegin(RACMagagedObjectFetch)

__block NSManagedObjectContext *ctx = nil;

beforeEach(^{
    ctx = contextForTest();
});

afterEach(^{
    ctx = nil;
});

describe(@"NSManagedObject", ^{
    __block BOOL executed;

    beforeEach(^{
        executed = NO;
    });

    it(@"creates a fetch request signal", ^{
        RACSignal *signal = Parent.rcd_all;
        [signal subscribeNext:^(NSFetchRequest *req) {
            expect(req).toNot.beNil();
            expect(req.entityName).to.equal(@"Parent");
            executed = YES;
        }];
        expect(executed).to.beTruthy();
    });

    it(@"inserts into context", ^{
        Parent *parent = [Parent insert];
        expect(parent).toNot.beNil();
        expect(parent.managedObjectContext).to.equal(ctx);
    });
});

SpecEnd

