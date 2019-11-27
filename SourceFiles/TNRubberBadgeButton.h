//
//  TNRubberBadgeButton.h
//  BaseProject
//
//  Created by Tony on 2017/8/15.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNRubberBadgeButton : UIButton

/** max distance, default is double button's width. Go beyond the limit will dismiss */
@property (nonatomic, assign) CGFloat maxDistance;

/** default is 0;it will be hidden and reset coordinate when value is zero; */
@property (nonatomic, assign) NSInteger badgeValue;


@end
