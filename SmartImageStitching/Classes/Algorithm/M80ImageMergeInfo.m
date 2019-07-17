//
//  M80ImageMergeInfo.m
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "M80ImageMergeInfo.h"
#import "M80Constraint.h"


@interface M80ImageMergeInfo ()

@end

@implementation M80ImageMergeInfo

- (void)calc
{
    M80ImageFingerprint *firstFingerprint = [M80ImageFingerprint fingerprint:_firstImage
                                                                        type:_type];
    M80ImageFingerprint *secondFingerprint= [M80ImageFingerprint fingerprint:_secondImage
                                                                        type:_type];
    
    NSArray *firstLines = [firstFingerprint lines];
    NSArray *secondLines= [secondFingerprint lines];
    
    NSInteger firstLinesCount = (NSInteger)[firstLines count];
    NSInteger secondLinesCount = (NSInteger)[secondLines count];
    
    //初始化动态规划所需要的数组
    int **matrix = (int **)malloc(sizeof(int *) * 2);
    for (int i = 0; i < 2; i++)
    {
        matrix[i] = (int *)malloc(sizeof(int) * (size_t)secondLinesCount);
    }
    for (NSInteger j = 0; j < secondLinesCount; j++)
    {
        matrix[0][j] = matrix[1][j] = 0;
        
    }
    
    //遍历并合并
    NSInteger length = 0,x = 0,y = 0;
    for (NSInteger i = [M80Constraint topOffset]; i < firstLinesCount - [M80Constraint bottomOffset]; i ++)
    {
        for (NSInteger  j = [M80Constraint topOffset]; j < secondLinesCount - [M80Constraint bottomOffset]; j++)
        {
            int64_t firstValue = [firstLines[i] longLongValue];
            int64_t secondValue = [secondLines[j] longLongValue];
            
            if ([self isX:firstValue
                  equalTo:secondValue])
            {
                int value = 0;
                if (j != 0)
                {
                    value = matrix[(i + 1) % 2][j-1] + 1;
                }
                matrix[i % 2][j] = value;
                
                if (value > length)
                {
                    length = value;
                    x = i;
                    y = j;
                }
            }
            else
            {
                matrix[i % 2][j] = 0;
            }
        }
    }
    
    //清理
    for (int i = 0; i < 2; i++)
        free(matrix[i]);
    free(matrix);
    
    
    //更新数据
    _length = length;
    _firstOffset = _firstImage.size.height - (x - length + 1);
    _secondOffset= _secondImage.size.height - (y - length + 1);
    
}



- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ 1st height %lf offset %d 2nd height %lf offset %d length %d"
            ,_type == M80FingerprintTypeCRC ? @"crc" : @"hist"
            ,_firstImage.size.height,(int)_firstOffset,
            _secondImage.size.height,(int)_secondOffset,
            (int)_length];
}


- (BOOL)isX:(int64_t)x
    equalTo:(int64_t)y
{
    if (_type == M80FingerprintTypeCRC)
    {
        return x == y;
    }
    else
    {
        return x * 1.1 >= y && x * 0.9 <= y;
    }
}

@end

