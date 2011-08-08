//
//  StoryDetailViewController.h
//  NewsBlur
//
//  Created by Samuel Clay on 6/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATPagingView.h"

@class NewsBlurAppDelegate;
@class StoryDetailView;

@interface StoryDetailViewController : ATPagingViewController {
    NewsBlurAppDelegate *appDelegate;

    UIProgressView *progressView;
    UIWebView *webView;
    UIToolbar *toolbar;
    UIBarButtonItem *buttonPrevious;
    UIBarButtonItem *buttonNext;
    
}

@property (nonatomic, retain) IBOutlet NewsBlurAppDelegate *appDelegate;

@end
