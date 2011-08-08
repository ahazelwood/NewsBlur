//
//  StoryDetailView.m
//  NewsBlur
//
//  Created by Samuel Clay on 8/4/11.
//  Copyright 2011 NewsBlur. All rights reserved.
//

#import "StoryDetailViewController.h"
#import "NewsBlurAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "StoryDetailView.h"

@implementation StoryDetailView

@synthesize appDelegate;
@synthesize progressView;
@synthesize webView;
@synthesize toolbar;
@synthesize buttonNext;
@synthesize buttonPrevious;

- (id)init {
    [self showStory];
    [self markStoryAsRead];   
    [self setNextPreviousButtons];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    NSLog(@"initWithFrame: %@", frame);
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setNextPreviousButtons {
    int nextIndex = [appDelegate indexOfNextStory];
    if (nextIndex == -1) {
        [buttonNext setTitle:@"Done"];
    } else {
        [buttonNext setTitle:@"Next Unread"];
    }
    
    int previousIndex = [appDelegate indexOfPreviousStory];
    if (previousIndex == -1) {
        [buttonPrevious setTitle:@"Done"];
    } else {
        [buttonPrevious setTitle:@"Previous"];
    }
    
    float unreads = [appDelegate unreadCount];
    float total = [appDelegate storyCount];
    float progress = (total - unreads) / total;

    [progressView setProgress:progress];
}

- (void)markStoryAsRead {
    if ([[appDelegate.activeStory objectForKey:@"read_status"] intValue] != 1) {
        [appDelegate markActiveStoryRead];
        
        NSString *urlString = @"http://www.newsblur.com/reader/mark_story_as_read";
        NSURL *url = [NSURL URLWithString:urlString];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:[appDelegate.activeStory objectForKey:@"id"] forKey:@"story_id"]; 
        [request setPostValue:[appDelegate.activeFeed objectForKey:@"id"] forKey:@"feed_id"]; 
        [request setDidFinishSelector:@selector(markedAsRead)];
        [request setDidFailSelector:@selector(markedAsRead)];
        [request setDelegate:self];
        [request startAsynchronous];
    }
}

- (void)markedAsRead {
    
}

- (void)showStory {
    NSLog(@"Loaded Story view: %@", appDelegate.activeStory);
    NSString *imgCssString = [NSString stringWithFormat:@"<style>"
                              "body {"
                              "  line-height: 18px;"
                              "  font-size: 13px;"
                              "  font-family: 'Lucida Grande',Helvetica, Arial;"
                              "  text-rendering: optimizeLegibility;"
                              "  margin: 0;"
                              "}"
                              "img {"
                              "  max-width: 300px;"
                              "  width: auto;"
                              "  height: auto;"
                              "}"
                              "blockquote {"
                              "  background-color: #F0F0F0;"
                              "  border-left: 1px solid #9B9B9B;"
                              "  padding: .5em 2em;"
                              "  margin: 0px;"
                              "}"
                              ".NB-header {"
                              "  font-size: 14px;"
                              "  font-weight: bold;"
                              "  background-color: #E0E0E0;"
                              "  border-bottom: 1px solid #A0A0A0;"
                              "  padding: 8px 8px 6px;"
                              "  text-shadow: 1px 1px 0 #EFEFEF;"
                              "  overflow: hidden;"
                              "}"
                              ".NB-story {"
                              "  margin: 12px 8px;"
                              "}"
                              ".NB-story-author {"
                              "    color: #969696;"
                              "    font-size: 10px;"
                              "    text-transform: uppercase;"
                              "    margin: 2px 8px 0px 0;"
                              "    text-shadow: 0 1px 0 #F9F9F9;"
                              "    float: left;"
                              "}"
                              ".NB-story-tags {"
                              "  overflow: hidden;"
                              "  line-height: 12px;"
                              "  height: 14px;"
                              "  padding: 5px 0 0 0;"
                              "  text-transform: uppercase;"
                              "}"
                              ".NB-story-tag {"
                              "    float: left;"
                              "    font-weight: normal;"
                              "    font-size: 9px;"
                              "    padding: 0px 4px 0px;"
                              "    margin: 0 4px 2px 0;"
                              "    background-color: #C6CBC3;"
                              "    color: #505050;"
                              "    text-shadow: 0 1px 0 #E7E7E7;"
                              "    border-radius: 4px;"
                              "    -moz-border-radius: 4px;"
                              "    -webkit-border-radius: 4px;"
                              "}"
                              ".NB-story-date {"
                              "  font-size: 11px;"
                              "  color: #252D6C;"
                              "}"
                              ".NB-story-title {"
                              "  clear: left;"
                              "  margin: 4px 0 4px;"
                              "}"
                              "</style>"];
    NSString *story_author      = @"";
    if ([appDelegate.activeStory objectForKey:@"story_authors"]) {
        NSString *author = [NSString stringWithFormat:@"%@",[appDelegate.activeStory objectForKey:@"story_authors"]];
        if (author && ![author isEqualToString:@"<null>"]) {
            story_author = [NSString stringWithFormat:@"<div class=\"NB-story-author\">%@</div>",author];
        }
    }
    NSString *story_tags      = @"";
    if ([appDelegate.activeStory objectForKey:@"story_tags"]) {
        NSArray *tag_array = [appDelegate.activeStory objectForKey:@"story_tags"];
        if ([tag_array count] > 0) {
            story_tags = [NSString stringWithFormat:@"<div class=\"NB-story-tags\"><div class=\"NB-story-tag\">%@</div></div>",
                          [tag_array componentsJoinedByString:@"</div><div class=\"NB-story-tag\">"]];
        }
    }
    NSString *storyHeader = [NSString stringWithFormat:@"<div class=\"NB-header\">"
                             "<div class=\"NB-story-date\">%@</div>"
                             "<div class=\"NB-story-title\">%@</div>"
                             "%@"
                             "%@"
                             "</div>", 
                             [story_tags length] ? [appDelegate.activeStory objectForKey:@"long_parsed_date"] : [appDelegate.activeStory objectForKey:@"short_parsed_date"],
                             [appDelegate.activeStory objectForKey:@"story_title"],
                             story_author,
                             story_tags];
    NSString *htmlString = [NSString stringWithFormat:@"%@ %@ <div class=\"NB-story\">%@</div>",
                            imgCssString, storyHeader, 
                            [appDelegate.activeStory objectForKey:@"story_content"]];
    [webView loadHTMLString:htmlString
                    baseURL:[NSURL URLWithString:[appDelegate.activeFeed 
                                                  objectForKey:@"feed_link"]]];
    
}

- (IBAction)doNextUnreadStory {
    int nextIndex = [appDelegate indexOfNextStory];
    if (nextIndex == -1) {
        [appDelegate.navigationController popToViewController:[appDelegate.navigationController.viewControllers objectAtIndex:0]  animated:YES];
    } else {
        [appDelegate setActiveStory:[[appDelegate activeFeedStories] objectAtIndex:nextIndex]];
        [self showStory];
        [self markStoryAsRead];
        [self setNextPreviousButtons];
    }
}

- (IBAction)doPreviousStory {
    int previousIndex = [appDelegate indexOfPreviousStory];
    if (previousIndex == -1) {
        [appDelegate.navigationController popToViewController:[appDelegate.navigationController.viewControllers objectAtIndex:0]  animated:YES];
    } else {
        [appDelegate setActiveStory:[[appDelegate activeFeedStories] objectAtIndex:previousIndex]];
        [self showStory];
        [self markStoryAsRead];
        [self setNextPreviousButtons];
    }
}

- (void)showOriginalSubview:(id)sender {
    NSURL *url = [NSURL URLWithString:[appDelegate.activeStory 
                                       objectForKey:@"story_permalink"]];
    [appDelegate showOriginalStory:url];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.webView = nil;
    self.appDelegate = nil;
    self.progressView = nil;
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = [request URL];
        [appDelegate showOriginalStory:url];
        //[url release];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

- (void)dealloc {
    [appDelegate release];
    [webView release];
    [progressView release];
    [toolbar release];
    [buttonNext release];
    [buttonPrevious release];
    [super dealloc];
}


@end

