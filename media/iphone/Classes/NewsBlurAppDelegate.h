//
//  NewsBlurAppDelegate.h
//  NewsBlur
//
//  Created by Samuel Clay on 6/16/10.
//  Copyright NewsBlur 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsBlurViewController;
@class FeedDetailViewController;
@class StoryDetailViewController;
@class LoginViewController;
@class LogoutDelegate;
@class OriginalStoryViewController;
@class StoryDetailView;

@interface NewsBlurAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    NewsBlurViewController *feedsViewController;
    FeedDetailViewController *feedDetailViewController;
    StoryDetailViewController *storyDetailViewController;
    LoginViewController *loginViewController;
    LogoutDelegate *logoutDelegate;
    OriginalStoryViewController *originalStoryViewController;
    StoryDetailView *storyDetailView;
    
    NSString * activeUsername;
    NSDictionary * activeFeed;
    NSArray * activeFeedStories;
    NSMutableArray * activeFeedStoryLocations;
    NSDictionary * activeStory;
    NSURL * activeOriginalStoryURL;
    int storyCount;
    NSInteger selectedIntelligence;
    NSMutableArray * recentlyReadStories;
    NSIndexPath * activeFeedIndexPath;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet NewsBlurViewController *feedsViewController;
@property (nonatomic, retain) IBOutlet FeedDetailViewController *feedDetailViewController;
@property (nonatomic, retain) IBOutlet StoryDetailViewController *storyDetailViewController;
@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;
@property (nonatomic, retain) IBOutlet LogoutDelegate *logoutDelegate;
@property (nonatomic, retain) IBOutlet OriginalStoryViewController *originalStoryViewController;
@property (nonatomic, retain) IBOutlet StoryDetailView *storyDetailView;

@property (readwrite, retain) NSString * activeUsername;
@property (readwrite, retain) NSDictionary * activeFeed;
@property (readwrite, retain) NSArray * activeFeedStories;
@property (readwrite, retain) NSMutableArray * activeFeedStoryLocations;
@property (readwrite, retain) NSDictionary * activeStory;
@property (readwrite, retain) NSURL * activeOriginalStoryURL;
@property (readwrite) int storyCount;
@property (readwrite) NSInteger selectedIntelligence;
@property (readwrite, retain) NSMutableArray * recentlyReadStories;
@property (readwrite, retain) NSIndexPath * activeFeedIndexPath;

- (void)showLogin;
- (void)loadFeedDetailView;
- (void)loadStoryDetailView;
- (void)reloadFeedsView;
- (void)hideNavigationBar:(BOOL)animated;
- (void)showNavigationBar:(BOOL)animated;
- (void)setTitle:(NSString *)title;
- (void)showOriginalStory:(NSURL *)url;
- (void)closeOriginalStory;
- (int)indexOfNextStory;
- (int)indexOfPreviousStory;
- (int)indexOfActiveStory;
- (void)setStories:(NSArray *)activeFeedStoriesValue;
- (void)addStories:(NSArray *)stories;
- (int)unreadCount;
- (void)markActiveStoryRead;
- (void)markActiveFeedAllRead;
- (void)calculateStoryLocations;
+ (int)computeStoryScore:(NSDictionary *)intelligence;

@end

