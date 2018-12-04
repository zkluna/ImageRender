//
//  ImpTypeHeader.m
//  HJBlurEffect
//
//  Created by rubick on 2018/10/29.
//  Copyright © 2018 linggao. All rights reserved.
//

#import "ImpTypeHeader.h"
#import <SDAutoLayout/SDAutoLayout.h>

@interface ImpTypeHeader()
@property (strong, nonatomic) UILabel *typeNameLab;
@end

@implementation ImpTypeHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if(self) {
        [self setUpTypeNameLab];
    }
    return self;
}
- (void)setUpTypeNameLab {
    _typeNameLab = [[UILabel alloc] init];
    [_typeNameLab setFrame:CGRectMake(14, 0, 300, 30)];
    _typeNameLab.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    _typeNameLab.textAlignment = NSTextAlignmentLeft;
    _typeNameLab.textColor = [UIColor purpleColor];
    [self.contentView addSubview:self.typeNameLab];
}
- (void)setTypeName:(NSString *)typeName {
    _typeName = typeName;
    [self.typeNameLab setText:typeName];
//    [self.typeNameLab sizeToFit];
}

@end
