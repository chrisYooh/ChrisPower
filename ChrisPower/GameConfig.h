//
//  GameConfig.h
//  ChrisPower
//
//  Created by Chris on 14/12/23.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Level;
@class ChrisMap;
@class ChrisMonster;
@class ChrisTower;
@class ChrisCannon;
@class GameConfig;

enum {
    GAME_OBJECT_MONSTER = 0,
    GAME_OBJECT_TOWER = 1,
    GAME_OBJECT_CANNON = 2,
};

@protocol GameConfigProtocol <NSObject>

- (id)initWithInstance:(id)object;
- (BOOL)updateWithInstance:(id)object;

@end

@interface GameConfig : NSObject <NSCoding>
{
    int currentPlayerId;
    
    int currentLevelPrimaryType;
    int currentLevelSecondaryType;
    
    int majorObject;
    int majorIndex;
    
    /* Level Store*/
    NSMutableDictionary *levelStore;

    /* Monster Store*/
    NSMutableDictionary *monsterStore;
    
    /* Tower Store*/
    NSMutableDictionary *towerStore;
    
    /* Cannon Store*/
    NSMutableDictionary *cannonStore;
}
@property (nonatomic) int currentPlayerId;
@property (nonatomic) int currentLevelPrimaryType;
@property (nonatomic) int currentLevelSecondaryType;

@property (nonatomic) int majorObject;
@property (nonatomic) int majorIndex;

+ (GameConfig *)globalConfig;
+ (void)reset;
+ (NSString *)configFilePath;

/* Developer interfaces */
+ (BOOL)saveConfigToFile;
+ (void)configReadFromLocal;

/* Level */
- (void)readOnlyEnumLevelWithBlock:(void(^)(const Level *, const NSString *))operation;
- (void)configOnlyReadOnlyEnumLevelWithBlock:(void(^)(const Level *, const NSString *))operation;
- (BOOL)updateStoreWithLevel:(Level *)level;
- (Level *)getTemplateLevelFromStoreWithPrimaryIndex:(int)priIndex secondaryIndex:(int)secIndex;
- (Level *)getCurrentTemplateLevelFromStore;

/* Monster */
- (void)readOnlyEnumMonsterWithBlock:(void(^)(const ChrisMonster *, const NSString *))operation;
- (BOOL)updateStoreWithMonster:(ChrisMonster *)monster;
- (ChrisMonster *)getTemplateMonsterFromStoreWithType:(int)type;
- (int)monsterNumber;

/* Tower */
- (void)readOnlyEnumTowerWithBlock:(void(^)(const ChrisTower *, const NSString *))operation;
- (BOOL)updateStoreWithTower:(ChrisTower *)tower;
- (ChrisTower *)getTemplateTowerFromStoreWithType:(int)type;
- (int)towerNumber;

/* Cannon */
- (void)readOnlyEnumCannonWithBlock:(void(^)(const ChrisCannon *, const NSString *))operation;
- (BOOL)updateStoreWithCannon:(ChrisCannon *)cannon;
- (ChrisCannon *)getTemplateCannonFromStoreWithType:(int)type;
- (int)cannonNumber;

@end
