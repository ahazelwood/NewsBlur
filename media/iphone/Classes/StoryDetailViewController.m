//
//  StoryDetailViewController.m
//  NewsBlur
//
//  Created by Samuel Clay on 6/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StoryDetailViewController.h"
#import "NewsBlurAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ATPagingView.h"
#import "StoryDetailView.h"


@implementation StoryDetailViewController

@synthesize appDelegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	NSLog(@"init storydetailviewcontroller: %@", nibNameOrNil);
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
//    [self showStory];
//    [self markStoryAsRead];   
    //    [self setNextPreviousButtons];
    
    [super viewWillAppear:animated];
    self.pagingView.currentPageIndex = 0;
    [self currentPageDidChangeInPagingView:self.pagingView];
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithTitle:@"Original" 
                                               style:UIBarButtonItemStyleBordered 
                                               target:self 
                                               action:@selector(showOriginalSubview:)
                                              ] autorelease];
	[super viewDidAppear:animated];
}

- (void)dealloc {
    [appDelegate release];
//    [webView release];
//    [progressView release];
//    [toolbar release];
//    [buttonNext release];
//    [buttonPrevious release];
    [super dealloc];
}

#pragma mark -
#pragma mark ATPagingViewDelegate methods

- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView {
    return 10;
}

- (UIView *)viewForPageInPagingView:(ATPagingView *)pagingView atIndex:(NSInteger)index {
    NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], nil];
    
    UIView *view = [pagingView dequeueReusablePage];
    if (view == nil) {
        view = [[[StoryDetailView alloc] init] autorelease];
        NSLog(@"view for page %d: %@in %@", index, view, [view superview]);
    }
    [appDelegate setActiveStory:[[appDelegate activeFeedStories] objectAtIndex:index]];
    view.backgroundColor = [colors objectAtIndex:index%3];
    return view;
}

- (void)currentPageDidChangeInPagingView:(ATPagingView *)pagingView {
    self.navigationItem.title = [NSString stringWithFormat:@"%d of %d", pagingView.currentPageIndex+1, pagingView.pageCount];
    NSLog(@"currentPage change: %d", pagingView.currentPageIndex);
}

@end
