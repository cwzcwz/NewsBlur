//
//  ShareViewController.m
//  Share Extension
//
//  Created by David Sinclair on 2015-12-18.
//  Copyright © 2015 NewsBlur. All rights reserved.
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController () <NSURLSessionDelegate>

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            return [itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL];
        }
    }
    
    return NO;
}

- (void)didSelectPost {
    for (NSExtensionItem *extensionItem in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in extensionItem.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *item, NSError * _Null_unspecified error) {
                    if (item) {
                        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.newsblur.NewsBlur-Group"];
                        NSString *host = [defaults objectForKey:@"share:host"];
                        NSString *token = [defaults objectForKey:@"share:token"];
                        NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
                        NSString *encodedURL = [item.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
                        NSString *encodedComments = [self.contentText stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
                        NSInteger time = [[NSDate date] timeIntervalSince1970];
                        NSLog(@"Host: %@; secret token: %@", host, token);
                        NSURLSession *mySession = [self configureMySession];
                        //    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/share_story/%@", host, token]];
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/add_site_load_script/%@/?url=%@&time=%@&comments=%@", host, token, encodedURL, @(time), encodedComments]];
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                        [request setHTTPMethod:@"GET"];
                        NSURLSessionTask *myTask = [mySession dataTaskWithRequest:request];
                        [myTask resume];
                        
                        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                    }
                }];
            }
        }
    }
}

- (NSURLSession *)configureMySession {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"group.com.newsblur.share"];
    // To access the shared container you set up, use the sharedContainerIdentifier property on your configuration object.
    config.sharedContainerIdentifier = @"group.com.newsblur.NewsBlur-Group";
    NSURLSession *mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    return mySession;
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end