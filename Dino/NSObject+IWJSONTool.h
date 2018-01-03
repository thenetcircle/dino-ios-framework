//
//  NSObject+IWJSONTool.h
//  Dino
//
//  Created by Devin Zhang on 18/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (IWJSONTool)

/**
 *  对象转换为JSONData
 *
 *  @return NSData
 */
- (nullable NSData *)JSONData;

/**
 *  对象转换为JSONString
 *
 *  @return NSString
 */
- (nullable NSString *)JSONString;

/**
 *  将JSONString转换为对象
 *
 *  @param jsonString json字符串
 *
 *  @return 对象
 */
+ (nullable id)objectFromJSONString:(nullable NSString *)jsonString;

/**
 *  将JSONString转换为对象
 *
 *  @param jsonString json字符串
 *
 *  @return 对象
 */
+ (nullable id)objectFromJSONData:(nullable NSData *)jsonData;

@end
