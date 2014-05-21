//
//  CustomScrollView.m
//  ganqishi
//
//  Created by Xing Kevin on 14-5-15.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import "CustomScrollView.h"

#define outlineGap          1.0f
#define inlineGap           3.0f
#define lineHolderHeight    59.0f
#define keyLabelHolderWidth 150.0f
#define keyLabelWidth       keyLabelHolderWidth - 2*inlineGap
#define keyLabelHeight      lineHolderHeight - 2*inlineGap
#define valueTextHolderWidth  (CGFloat)(self.bounds.size.width - outlineGap*3 - keyLabelHolderWidth*2)/2
#define valueTextWidth      valueTextHolderWidth - 2*inlineGap


@implementation CustomScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// 设置浏览模式还是编辑模式
- (void)setMode:(NSScrollViewMode)mode
{
    for (UIView *subView in self.subviews)
    {
        if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *)subView;
            if (mode == EditMode)
            {
                textField.enabled = YES;
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.backgroundColor = BACKGROUND_GRAY;
                textField.attributedText = [[NSAttributedString alloc] initWithString:textField.text attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil]];
            }
            else
            {
                textField.enabled = NO;
                textField.borderStyle = UITextBorderStyleNone;
                textField.backgroundColor = [UIColor whiteColor];
                textField.attributedText = [[NSAttributedString alloc] initWithString:textField.text attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], NSForegroundColorAttributeName, nil]];
            }
        }
        else if ([subView isKindOfClass:[UITextView class]])
        {
            UITextView *textView = (UITextView *)subView;
            if (mode == EditMode)
            {
                textView.editable = YES;
                textView.backgroundColor = BACKGROUND_GRAY;
                textView.layer.cornerRadius = 5.0f;
                textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil]];
            }
            else
            {
                textView.editable = NO;
                textView.backgroundColor = [UIColor whiteColor];
                textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:[NSDictionary dictionaryWithObjectsAndKeys:BACKGROUND_GRAY, NSForegroundColorAttributeName, nil]];
            }
        }
    }
}

// 设置Scroll View的内容
- (void)setValuesAndKeys:(NSArray *)arrValuesAndKeys
{
    for (int i=0; i<arrValuesAndKeys.count; i++)
    {
        NSDictionary *dicOnePair = [arrValuesAndKeys objectAtIndex:i];
        // 计算出orginPoint
        int row = i/2;
        BOOL isRight = i%2;
        CGFloat holderY = (lineHolderHeight + outlineGap)*row;
        CGFloat holderX = 0;
        if (isRight)
        {
            holderX = keyLabelHolderWidth + valueTextHolderWidth + outlineGap*2;
        }
        
        NSString *key = [[dicOnePair allKeys] lastObject];
        NSString *value = [dicOnePair objectForKey:key];
        
        UIView *keyLabelHolder = [[UIView alloc] initWithFrame:CGRectMake(holderX, holderY, keyLabelHolderWidth, lineHolderHeight)];
        keyLabelHolder.backgroundColor = [UIColor whiteColor];
        [self addSubview:keyLabelHolder];
        
        UIView *valueTextHolder = [[UIView alloc] initWithFrame:CGRectMake(holderX+keyLabelHolderWidth+outlineGap, holderY, valueTextHolderWidth, lineHolderHeight)];
        valueTextHolder.backgroundColor = [UIColor whiteColor];
        [self addSubview:valueTextHolder];
        
        
        
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(holderX+inlineGap, holderY+inlineGap, keyLabelWidth, keyLabelHeight)];
        keyLabel.textAlignment = NSTextAlignmentRight;
        keyLabel.backgroundColor = [UIColor whiteColor];
        keyLabel.attributedText = [[NSAttributedString alloc] initWithString:key attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor orangeColor], NSForegroundColorAttributeName, nil]];
        keyLabel.tag = i*2;
        [self addSubview:keyLabel];
        
        UITextField *valueText = [[UITextField alloc] initWithFrame:CGRectMake(holderX+keyLabelHolderWidth+outlineGap+inlineGap, holderY+inlineGap, valueTextWidth, keyLabelHeight)];
        valueText.clearsOnBeginEditing = YES;
        valueText.text = value;
        valueText.tag = i*2+1;
        [self addSubview:valueText];
    }
}

// 获取Scroll View的内容
- (NSDictionary *)getValuesAndKeys
{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    
    NSArray *subViews = [self subviews];
    
    // 过滤掉所有非UILabel或UITextField的subView
    NSMutableArray *allLabelAndTextFields = [[NSMutableArray alloc] init];
    for (int i=0; i< subViews.count; i++)
    {
        UIView *subView = [subViews objectAtIndex:i];
        if ([subView isKindOfClass:[UILabel class]] || [subView isKindOfClass:[UITextField class]])
        {
            [allLabelAndTextFields addObject:subView];
        }
    }
    
    // 通过tag排序所有的UILabel和UITextField
    NSMutableArray *sortedLabelAndTextFields = [[NSMutableArray alloc] init];

    for (int i=0; i<allLabelAndTextFields.count; i++)
    {
        int iMaxTagIndex = 0;
        int iMaxTag = ((UIView *)[allLabelAndTextFields objectAtIndex:iMaxTagIndex]).tag;
        
        for (int j=1; j<allLabelAndTextFields.count; j++)
        {
            int iTag = ((UIView *)[allLabelAndTextFields objectAtIndex:j]).tag;
            if (iTag > iMaxTag)
            {
                iMaxTag = iTag;
                iMaxTagIndex = j;
            }
        }
        [sortedLabelAndTextFields insertObject:[allLabelAndTextFields objectAtIndex:iMaxTagIndex] atIndex:0];
        [allLabelAndTextFields removeObjectAtIndex:iMaxTagIndex];
        i = 0;
    }
    [sortedLabelAndTextFields insertObject:[allLabelAndTextFields objectAtIndex:0] atIndex:0];
    
    
    
    for (int i=0; i<sortedLabelAndTextFields.count; i=i+2)
    {
        UILabel *keyLabel = [sortedLabelAndTextFields objectAtIndex:i];
        UITextField *valueText = [sortedLabelAndTextFields objectAtIndex:i+1];
        [ret setObject:valueText.text forKey:keyLabel.text];
    }
    
    
    return ret;
}

@end
