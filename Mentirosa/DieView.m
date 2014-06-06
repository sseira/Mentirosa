//
//  DieView.m
//  Mentirosa
//
//  Created by Santiago Seira on 11/25/13.
//  Copyright (c) 2013 Santiago. All rights reserved.
//

#import "DieView.h"

@implementation DieView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = nil;
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}



-(void)awakeFromNib {
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}


-(void)setValue:(NSString *)value {
    _value = value;
    [self setNeedsDisplay];
}



#define CORNER_FONT_STANDARD_HEIGHT 180.0
#define CORNER_RADIUS 15.0

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }

- (void)drawRect:(CGRect)rect
{
    [[UIColor blueColor] setFill];
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
    [roundedRect addClip];
    [[UIColor whiteColor] setFill];

    UIRectFill(self.bounds);
    
    
    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
    
    [self drawContentsInRect:rect];
}




#define PIP_FONT_SCALE_FACTOR 0.012

-(void)drawContentsInRect: (CGRect)rect {
    if (self.value) {

        UIImage *faceImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", self.value]];
        if (faceImage) {
            [faceImage drawInRect:rect];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:faceImage];
            imageView.bounds = rect;
        }
        
    }
}

@end
