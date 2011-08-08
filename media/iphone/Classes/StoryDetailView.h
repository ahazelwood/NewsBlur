//
//  StoryDetailView.h
//  NewsBlur
//
//  Created by Samuel Clay on 8/4/11.
//  Copyright 2011 NewsBlur. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsBlurAppDelegate;

@interface StoryDetailView : UIView {
    NewsBlurAppDelegate *appDelegate;
    
    UIProgressView *progressView;
    UIWebView *webView;
    UIToolbar *toolbar;
    UIBarButtonItem *buttonPrevious;
    UIBarButtonItem *buttonNext;
    
}

@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonPrevious;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonNext;
@property (nonatomic, retain) IBOutlet NewsBlurAppDelegate *appDelegate;

- (void)setNextPreviousButtons;
- (void)markStoryAsRead;
- (void)showStory;
- (void)showOriginalSubview:(id)sender;
- (IBAction)doNextUnreadStory;
- (IBAction)doPreviousStory;
- (void)markedAsRead;

@end
