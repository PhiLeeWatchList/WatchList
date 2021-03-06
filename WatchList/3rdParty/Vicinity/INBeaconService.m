//
//  INBlueToothService.m
//  Vicinity
//
//  Created by Ben Ford on 10/28/13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Instrument Marketing Inc
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "INBeaconService.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CLBeacon+Ext.h"
#import "CBPeripheralManager+Ext.h"
#import "CBCentralManager+Ext.h"
#import "CBUUID+Ext.h"

#import "GCDSingleton.h"
#import "EasedValue.h"

#define DEBUG_CENTRAL YES
#define DEBUG_PERIPHERAL YES
#define DEBUG_PROXIMITY NO

#define UPDATE_INTERVAL 1.0f

@interface INBeaconService() <CBPeripheralManagerDelegate, CBCentralManagerDelegate>

@property (nonatomic, strong) NSArray *testArray;
@property (nonatomic, strong) NSMutableArray *testIdentifierArray;
@property (nonatomic, strong) NSMutableArray *foundIdentifierArray;


@end

@implementation INBeaconService
{
    //TODO: the identifier must be changed to handle transmit beacon vs. lookFor beacons
    CBUUID *identifier;
    INDetectorRange identifierRange;
    
    CBCentralManager *centralManager;
    CBPeripheralManager *peripheralManager;
    
    NSMutableSet *delegates;
    
    EasedValue *easedProximity;
    
    NSTimer *detectorTimer;
    
    BOOL bluetoothIsEnabledAndAuthorized;
    NSTimer *authorizationTimer;
    
}

#pragma mark Singleton
+ (INBeaconService *)singleton
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] initWithIdentifier:SINGLETON_IDENTIFIER];
    });
}
#pragma mark -


//+ (instancetype)singleton
//{
//    static INBeaconService *singleton = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        singleton = [[self alloc] initWithIdentifier:SINGLETON_IDENTIFIER];
//        // Do any other initialisation stuff here
//    });
//    return singleton;
//}

- (id)initWithIdentifier:(NSString *)theIdentifier
{
    if ((self = [super init])) {
        identifier = [CBUUID UUIDWithString:theIdentifier];
        
        
        self.testArray = [[NSArray alloc] init];
        
        self.testArray =  @[@"CB284D88-5317-4FB4-9621-C5A3A49E6150",
                            @"CB284D88-5317-4FB4-9621-C5A3A49E6151",
                            @"CB284D88-5317-4FB4-9621-C5A3A49E6152",
                            @"CB284D88-5317-4FB4-9621-C5A3A49E6153",
                            @"CB284D88-5317-4FB4-9621-C5A3A49E6154",
                            @"CB284D88-5317-4FB4-9621-C5A3A49E6155",
                            @"CB284D88-5317-4FB4-9621-C5A3A49E6156",
                            @"CB284D88-5317-4FB4-9621-C5A3A49E6157"];
        
        self.testIdentifierArray = [[NSMutableArray alloc] initWithCapacity:self.testArray.count];
        self.foundIdentifierArray = [[NSMutableArray alloc] initWithCapacity:self.testArray.count];
        for (int i; i<self.testArray.count; i++) {
            [self.testIdentifierArray addObject:[CBUUID UUIDWithString:self.testArray[i]]];
        }
        
        
        delegates = [[NSMutableSet alloc] init];
        
        easedProximity = [[EasedValue alloc] init];
        
        // use to track changes to this value
        bluetoothIsEnabledAndAuthorized = [self hasBluetooth];
        [self startAuthorizationTimer];
    }
    return self;
}

- (void)changeIdentifier:(NSString *)theIdentifier
{
    NSLog(@"change identifier: %@", theIdentifier);
    identifier = [CBUUID UUIDWithString:theIdentifier];
}

- (void)addDelegate:(id<INBeaconServiceDelegate>)delegate
{
    [delegates addObject:delegate];
}

- (void)removeDelegate:(id<INBeaconServiceDelegate>)delegate
{
    [delegates removeObject:delegate];
}

- (void)performBlockOnDelegates:(void(^)(id<INBeaconServiceDelegate> delegate))block
{
    [self performBlockOnDelegates:block complete:nil];
}

- (void)performBlockOnDelegates:(void(^)(id<INBeaconServiceDelegate> delegate))block complete:( void(^)(void))complete
{
    for (id<INBeaconServiceDelegate>delegate in delegates) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block)
                block(delegate);
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (complete)
            complete();
    });
    
}

- (void)startDetecting
{
    if (![self canMonitorBeacons])
        return;
    
    [self startDetectingBeacons];
}

- (void)startScanning
{
    NSLog(@"I'm scanning: %@", self.testIdentifierArray);
    
    NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)};
    
    [centralManager scanForPeripheralsWithServices:self.testIdentifierArray options:scanOptions];
    _isDetecting = YES;
}

- (void)stopDetecting
{
    _isDetecting = NO;
    
    [centralManager stopScan];
    centralManager = nil;
    
    [detectorTimer invalidate];
    detectorTimer = nil;
}

- (void)startBroadcasting
{
    NSLog(@"I'm Broadcasting: %@", [identifier UUIDString]);
    if (![self canBroadcast])
        return;
    
    [self startBluetoothBroadcast];
    
}

- (void)stopBroadcasting
{
    _isBroadcasting = NO;
    
    // stop advertising beacon data.
    [peripheralManager stopAdvertising];
    peripheralManager = nil;
}



- (void)startDetectingBeacons
{
    if (!centralManager)
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];//centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    //centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionRestoreIdentifierKey: @"watchlistCentralManager" }];
    
    detectorTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self
                                                   selector:@selector(reportRangesToDelegates:) userInfo:nil repeats:YES];
}

- (void)startBluetoothBroadcast
{
    // start broadcasting if it's stopped
    if (!peripheralManager) {
        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
}

- (void)startAdvertising
{
    
    NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey:@"watchlist-peripheral",
                                      CBAdvertisementDataServiceUUIDsKey:@[identifier]};
    
    // Start advertising over BLE
    [peripheralManager startAdvertising:advertisingData];
    
    _isBroadcasting = YES;
}

- (BOOL)canBroadcast
{
    // iOS6 can't detect peripheral authorization so just assume it works.
    // ARC complains if we use @selector because `authorizationStatus` is ambiguous
    SEL selector = NSSelectorFromString(@"authorizationStatus");
    if (![[CBPeripheralManager class] respondsToSelector:selector])
        return YES;
    
    CBPeripheralManagerAuthorizationStatus status = [CBPeripheralManager authorizationStatus];
    
    BOOL enabled = (status == CBPeripheralManagerAuthorizationStatusAuthorized ||
                    status == CBPeripheralManagerAuthorizationStatusNotDetermined);
    
    if (!enabled)
        NSLog(@"bluetooth not authorized");
    
    return enabled;
}

- (BOOL)canMonitorBeacons
{
    return YES;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    CBUUID *uuid = [advertisementData[CBAdvertisementDataServiceUUIDsKey] firstObject];
    if(uuid == nil) {
        //check overflow if in background.
        uuid = [advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] firstObject];
    }
    
    if (DEBUG_PERIPHERAL) {
        NSLog(@"did discover peripheral: %@, data: %@, %1.2f", [peripheral.identifier UUIDString], advertisementData, [RSSI floatValue]);
        NSLog(@"service uuid: %@", [uuid representativeString]);
    }
    
    //NSLog(@"testIdentifierArray count %lu", (unsigned long)self.testIdentifierArray.count);
    
    
    for (int i=0; i<self.testIdentifierArray.count; i++) {
        //NSLog(@"peripheral: %@ testArray: %@", [peripheral.identifier UUIDString], testArray[i]);
        //NSLog(@"service uuid: %@ testUUID: %@", [uuid representativeString], [self.testIdentifierArray[i] UUIDString]);
        if ([[[uuid representativeString] uppercaseString] isEqualToString:[self.testIdentifierArray[i] UUIDString]]) {
            
            //NSLog(@"...did discover peripheral: %@, data: %@, %1.2f", [self.testIdentifierArray[i] UUIDString], advertisementData, [RSSI floatValue]);
            
            [self addNewFoundIdentifierArray:uuid];
            
            //CBUUID *uuid = [advertisementData[CBAdvertisementDataServiceUUIDsKey] firstObject];
            //NSLog(@"...service uuid: %@", [uuid representativeString]);
        }
    }
    
    identifierRange = [self convertRSSItoINProximity:[RSSI floatValue]];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (DEBUG_CENTRAL)
        NSLog(@"-- central state changed: %@", centralManager.stateString);
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self startScanning];
    }
    
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    
//    NSArray *centralManagerIdentifiers =
//    launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
}

#pragma mark -

- (void)reportRangesToDelegates:(NSTimer *)timer
{
    [self performBlockOnDelegates:^(id<INBeaconServiceDelegate>delegate) {
        
        
        //TODO: report the correct id
        //        for (int i; i<self.testIdentifierArray.count; i++) {
        //
        //            [delegate service:self foundDeviceUUID:[self.testIdentifierArray[i] representativeString] withRange:identifierRange];
        //        }
        
        for (int i=0; i<self.foundIdentifierArray.count; i++) {
            
            [delegate service:self foundDeviceUUID:[self.foundIdentifierArray[i] representativeString] withRange:identifierRange];
        }
        
        //        [delegate service:self foundDeviceUUID:[identifier representativeString] withRange:identifierRange];
        
    } complete:^{
        // timeout the beacon to unknown position
        // if it's still active it will be updated by central delegate "didDiscoverPeripheral"
        identifierRange = INDetectorRangeUnknown;
    }];
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (DEBUG_PERIPHERAL)
        NSLog(@"-- peripheral state changed: %@", peripheral.stateString);
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self startAdvertising];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (DEBUG_PERIPHERAL) {
        if (error)
            NSLog(@"error starting advertising: %@", [error localizedDescription]);
        else
            NSLog(@"did start advertising");
    }
}
#pragma mark -

- (INDetectorRange)convertRSSItoINProximity:(NSInteger)proximity
{
    // eased value doesn't support negative values
    easedProximity.value = labs(proximity);
    [easedProximity update];
    proximity = easedProximity.value * -1.0f;
    
    if (DEBUG_PROXIMITY)
        NSLog(@"proximity: %ld", (long)proximity);
    
    
    if (proximity < -70)
        return INDetectorRangeFar;
    if (proximity < -55)
        return INDetectorRangeNear;
    if (proximity < 0)
        return INDetectorRangeImmediate;
    
    return INDetectorRangeUnknown;
}

- (BOOL)hasBluetooth
{
    return [self canBroadcast] && peripheralManager.state == CBPeripheralManagerStatePoweredOn;
}

- (void)startAuthorizationTimer
{
    authorizationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self
                                                        selector:@selector(checkBluetoothAuth:)
                                                        userInfo:nil repeats:YES];
}

- (void)checkBluetoothAuth:(NSTimer *)timer
{
    if (bluetoothIsEnabledAndAuthorized != [self hasBluetooth]) {
        
        bluetoothIsEnabledAndAuthorized = [self hasBluetooth];
        [self performBlockOnDelegates:^(id<INBeaconServiceDelegate>delegate) {
            if ([delegate respondsToSelector:@selector(service:bluetoothAvailable:)])
                [delegate service:self bluetoothAvailable:bluetoothIsEnabledAndAuthorized];
        }];
    }
}

- (void) addNewFoundIdentifierArray:(CBUUID *) newIdentifier {
    if (self.foundIdentifierArray.count<=0) {
        
        [self.foundIdentifierArray addObject:newIdentifier];
    }
    BOOL canAdd = YES;
    for (int i=0; i<self.foundIdentifierArray.count; i++) {
        if ([[newIdentifier UUIDString] isEqualToString:[self.foundIdentifierArray[i] UUIDString]]) {
            canAdd = NO;
        }
    }
    
    if(canAdd) {
        NSLog(@"adding: %@", [newIdentifier UUIDString]);
        [self.foundIdentifierArray addObject:newIdentifier];
    }
}
@end
