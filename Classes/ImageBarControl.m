/*
 * Copyright (c) 2007, 2008 Stuart Carnie
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither Stuart Carnie nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY Stuart Carnie ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL Stuart Carnie BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

#import "ImageBarControl.h"
#import "CocoaUtility.h"

@interface ImageBarControl()

- (void)buttonSelected:(UIButton*)button;
- (void)loadButtonsFromItems:(NSArray*)items;

@end

@implementation ImageBarControl

const double kButtonYPosition = 0.0;

@synthesize selectedSegmentIndex = _selectedSegment;

#pragma mark -
#pragma mark Helper Functions

CGSize getSizeFromImage(UIButton *button) {
	return button.currentImage.size;
}

#pragma mark -
#pragma mark ImageBarControl

- (id)initWithItems:(NSArray*)items {
	self = [super init];
	if (self) {
		_segments = [NSMutableArray new];
		[self loadButtonsFromItems:items];
		[self setSelectedSegmentIndex:0];
	}
	return self;
}

- (void)frameButton:(UIButton*)button atX:(float*)x {
	CGSize buttonSize = getSizeFromImage(button);
	button.frame = CGRectMake(*x, kButtonYPosition, buttonSize.width, buttonSize.height);
	*x += buttonSize.width;
}

- (void)layoutSubviews {
	float totalWidth = 0;
	for(UIButton* button in _segments)
		totalWidth += getSizeFromImage(button).width;
		
	float startX = (self.frame.size.width / 2.0) - (totalWidth / 2.0);
	for(UIButton* button in _segments)
		[self frameButton:button atX:&startX];
}

- (UIButton*)createToolButtonWithImage:(NSString*)imageName andSelectedImage:(NSString*)selectedImageName {
	UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];

	view.showsTouchWhenHighlighted = NO;
	view.adjustsImageWhenHighlighted = NO;
	
	[view setImage:[UIImage imageFromResource:imageName] forState:UIControlStateNormal];
	[view setImage:[UIImage imageFromResource:selectedImageName] forState:UIControlStateSelected];
	[view addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:view];
	return view;
}

- (NSUInteger)numberOfSegments {
	return [_segments count];
}

- (void)setSelectedSegmentIndex:(NSInteger)value {
	if (value < 0 || value >= [_segments count])
		return;
	
	if (_selectedButton) {
		_selectedButton.selected = NO;
	}
	_selectedSegment = value;
	_selectedButton = [_segments objectAtIndex:_selectedSegment];
	_selectedButton.selected = YES;
}

- (void)loadButtonsFromItems:(NSArray*)items {
	int count = [items count];
	float totalWidth;
	for (int i=0; i<count; i+=2) {
		NSString *image = [items objectAtIndex:i];
		NSString *selectedImage = [items objectAtIndex:i+1];
		UIButton *button = [self createToolButtonWithImage:image andSelectedImage:selectedImage];
		button.tag = i/2;
		totalWidth += getSizeFromImage(button).width;
		[_segments addObject:button];
		[button release];
	}
	
	// FIXME: This height should be calculated
	self.frame = CGRectMake(0, 0, totalWidth, 20);
}

- (void)buttonSelected:(UIButton*)button {	
	self.selectedSegmentIndex = button.tag;
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)dealloc {
	[_segments release];
    [super dealloc];
}

@end
