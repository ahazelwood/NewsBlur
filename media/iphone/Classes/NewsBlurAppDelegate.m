//
//  NewsBlurAppDelegate.m
//  NewsBlur
//
//  Created by Samuel Clay on 6/16/10.
//  Copyright NewsBlur 2010. All rights reserved.
//

#import "NewsBlurAppDelegate.h"
#import "NewsBlurViewController.h"
#import "FeedDetailViewController.h"
#import "StoryDetailViewController.h"
#import "StoryDetailView.h"

#import "LoginViewController.h"
#import "OriginalStoryViewController.h"

@implementation NewsBlurAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize feedsViewController;
@synthesize feedDetailViewController;
@synthesize storyDetailViewController;
@synthesize loginViewController;
@synthesize originalStoryViewController;
@synthesize storyDetailView;

@synthesize logoutDelegate;
@synthesize activeUsername;
@synthesize activeFeed;
@synthesize activeFeedStories;
@synthesize activeFeedStoryLocations;
@synthesize activeStory;
@synthesize storyCount;
@synthesize selectedIntelligence;
@synthesize activeOriginalStoryURL;
@synthesize recentlyReadStories;
@synthesize activeFeedIndexPath;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    navigationController.viewControllers = [NSArray arrayWithObject:feedsViewController];
    
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    
    [feedsViewController fetchFeedList];
    
	return YES;
}

- (void)viewDidLoad {
    self.selectedIntelligence = 1;
    [self setRecentlyReadStories:[NSMutableArray array]];
}

- (void)dealloc {
    NSLog(@"Dealloc on AppDelegate");
    [feedsViewController release];
    [feedDetailViewController release];
    [storyDetailViewController release];
    [loginViewController release];
    [originalStoryViewController release];
    [navigationController release];
    [window release];
    [activeUsername release];
    [activeFeed release];
    [activeFeedStories release];
    [activeFeedStoryLocations release];
    [activeStory release];
    [activeOriginalStoryURL release];
    [recentlyReadStories release];
    [activeFeedIndexPath release];
    [super dealloc];
}

- (void)hideNavigationBar:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)showNavigationBar:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

#pragma mark -
#pragma mark Views

- (void)showLogin {
    UINavigationController *navController = self.navigationController;
    [navController presentModalViewController:loginViewController animated:YES];
}

- (void)reloadFeedsView {
    [self setTitle:@"NewsBlur"];
    [feedsViewController fetchFeedList];
    [loginViewController dismissModalViewControllerAnimated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.16f green:0.36f blue:0.46 alpha:0.6];
}
   
- (void)loadFeedDetailView {
    UINavigationController *navController = self.navigationController;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"All" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self setStories:nil];
    navController.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    [navController pushViewController:feedDetailViewController animated:YES];
    [feedDetailViewController fetchFeedDetail:1];
    [self showNavigationBar:YES];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.16f green:0.36f blue:0.46 alpha:0.8];
}

- (void)loadStoryDetailView {
    UINavigationController *navController = self.navigationController;   
    [navController pushViewController:storyDetailViewController animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.16f green:0.36f blue:0.46 alpha:0.9];
}

- (void)setTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont boldSystemFontOfSize:16.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:title];
    [label sizeToFit];
    [navigationController.navigationBar.topItem setTitleView:label];
    [label release];
}

- (void)showOriginalStory:(NSURL *)url {
    self.activeOriginalStoryURL = url;
    UINavigationController *navController = self.navigationController;
    [navController presentModalViewController:originalStoryViewController animated:YES];
}

- (void)closeOriginalStory {
    [originalStoryViewController dismissModalViewControllerAnimated:YES];
}

- (int)indexOfNextStory {
    int activeIndex = [self indexOfActiveStory];
    int readStatus = -1;
    NSLog(@"ActiveStory: %d/%d", activeIndex, self.storyCount);
    for (int i=activeIndex+1; i < self.storyCount; i++) {
        NSDictionary *story = [activeFeedStories objectAtIndex:i];
        readStatus = [[story objectForKey:@"read_status"] intValue];
        NSLog(@"readStatus at %d: %d", i, readStatus);
        if (readStatus == 0) {
            NSLog(@"NextStory: %d", i);
            return i;
        }
    }
    for (int i=activeIndex; i >= 0; i--) {
        NSDictionary *story = [activeFeedStories objectAtIndex:i];
        readStatus = [[story objectForKey:@"read_status"] intValue];
        NSLog(@"readStatus at %d: %d", i, readStatus);
        if (readStatus == 0) {
            NSLog(@"NextStory: %d", i);
            return i;
        }
    }
    return -1;
}

- (int)indexOfPreviousStory {
    NSInteger activeIndex = [self indexOfActiveStory];
    return MAX(-1, activeIndex-1);
}

- (int)indexOfActiveStory {
    for (int i=0; i < self.storyCount; i++) {
        NSDictionary *story = [activeFeedStories objectAtIndex:i];
        if ([activeStory objectForKey:@"id"] == [story objectForKey:@"id"]) {
            return i;
        }
    }
    return -1;
}

- (int)unreadCount {
    int ps = [[self.activeFeed objectForKey:@"ps"] intValue];
    int nt = [[self.activeFeed objectForKey:@"nt"] intValue];
    int ng = [[self.activeFeed objectForKey:@"ng"] intValue];
    return ps + nt + ng;
}

- (void)addStories:(NSArray *)stories {
    self.activeFeedStories = [self.activeFeedStories arrayByAddingObjectsFromArray:stories];
    self.storyCount = [self.activeFeedStories count];
    [self calculateStoryLocations];
}

- (void)setStories:(NSArray *)activeFeedStoriesValue {
    self.activeFeedStories = activeFeedStoriesValue;
    self.storyCount = [self.activeFeedStories count];
    [self setRecentlyReadStories:[NSMutableArray array]];
    [self calculateStoryLocations];
}

- (void)markActiveStoryRead {
    int activeIndex = [self indexOfActiveStory];
    NSDictionary *story = [activeFeedStories objectAtIndex:activeIndex];
    [story setValue:[NSNumber numberWithInt:1] forKey:@"read_status"];
    [self.recentlyReadStories addObject:[NSNumber numberWithInt:activeIndex]];
    int score = [NewsBlurAppDelegate computeStoryScore:[story objectForKey:@"intelligence"]];
    if (score > 0) {
        int unreads = [[activeFeed objectForKey:@"ps"] intValue] - 1;
        [self.activeFeed setValue:[NSNumber numberWithInt:unreads] forKey:@"ps"];
    } else if (score == 0) {
        int unreads = [[activeFeed objectForKey:@"nt"] intValue] - 1;
        NSLog(@"Neutral story: %@ -- %d", [activeFeed objectForKey:@"nt"], unreads);
        [self.activeFeed setValue:[NSNumber numberWithInt:unreads] forKey:@"nt"];
    } else if (score < 0) {
        int unreads = [[activeFeed objectForKey:@"ng"] intValue] - 1;
        [self.activeFeed setValue:[NSNumber numberWithInt:unreads] forKey:@"ng"];
    }
    NSLog(@"Marked read %d: %@: %d", activeIndex, self.recentlyReadStories, score);
}

- (void)markActiveFeedAllRead {    
    [self.activeFeed setValue:[NSNumber numberWithInt:0] forKey:@"ps"];
    [self.activeFeed setValue:[NSNumber numberWithInt:0] forKey:@"nt"];
    [self.activeFeed setValue:[NSNumber numberWithInt:0] forKey:@"ng"];
}

- (void)calculateStoryLocations {
    self.activeFeedStoryLocations = [NSMutableArray array];
    for (int i=0; i < self.storyCount; i++) {
        NSDictionary *story = [self.activeFeedStories objectAtIndex:i];
        int score = [NewsBlurAppDelegate computeStoryScore:[story objectForKey:@"intelligence"]];
        if (score >= self.selectedIntelligence) {
            NSNumber *location = [NSNumber numberWithInt:i];
            [self.activeFeedStoryLocations addObject:location];
        }
    }
}

+ (int)computeStoryScore:(NSDictionary *)intelligence {
    int score = 0;
    int title = [[intelligence objectForKey:@"title"] intValue];
    int author = [[intelligence objectForKey:@"author"] intValue];
    int tags = [[intelligence objectForKey:@"tags"] intValue];

    int score_max = MAX(title, MAX(author, tags));
    int score_min = MIN(title, MIN(author, tags));

    if (score_max > 0)      score = score_max;
    else if (score_min < 0) score = score_min;
    
    if (score == 0) score = [[intelligence objectForKey:@"feed"] integerValue];

//    NSLog(@"%d/%d -- %d: %@", score_max, score_min, score, intelligence);
    return score;
}

@end
