//
//  ATMailHelper.m
//  AP
//
//  Created by Christopher Atlan on 25.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ATMailHelper.h"

#import <WebKit/WebKit.h>

#define MAIL_BUNDLE_ID @"com.apple.mail"

@interface ATMailHelper ()

+ (BOOL)isAppleMailDefault;
+ (void)mailWebArchive:(WebArchive *)webArchive
				 title:(NSString *)aTitle
				   URL:(NSString *)aURL
	alternateMailToURL:(NSURL *)alternateMailToURL;

@end

@implementation ATMailHelper

+ (void)mailHTMLString:(NSString *)string
			   baseURL:(NSURL *)URL
			   subject:(NSString *)aSubject
	alternateMailToURL:(NSURL *)alternateMailToURL
{
	if (![ATMailHelper isAppleMailDefault]) {
		[[NSWorkspace sharedWorkspace] openURL:alternateMailToURL];
		return;
	}
	
	NSData *htmlData = [string dataUsingEncoding:NSUTF8StringEncoding];
	WebResource *mainResource = [[WebResource alloc] initWithData:htmlData
															  URL:URL
														 MIMEType:@"text/html"
												 textEncodingName:@"utf-8"
														frameName:nil];
	
	WebArchive *webArchive = [[WebArchive alloc] initWithMainResource:mainResource
														 subresources:nil
													 subframeArchives:nil];
	[mainResource release];
	[ATMailHelper mailWebArchive:webArchive title:aSubject URL:@"" alternateMailToURL:alternateMailToURL];
	[webArchive release];
}

+ (void)mailWebArchive:(WebArchive *)webArchive
				 title:(NSString *)aTitle
				   URL:(NSString *)aURL
	alternateMailToURL:(NSURL *)alternateMailToURL
{
	NSData* targetBundleID = [MAIL_BUNDLE_ID dataUsingEncoding:NSUTF8StringEncoding];
	NSAppleEventDescriptor *targetDescriptor = nil;
	NSAppleEventDescriptor *appleEvent = nil;
	
	targetDescriptor = [NSAppleEventDescriptor descriptorWithDescriptorType:typeApplicationBundleID
																	   data:targetBundleID];
	appleEvent = [NSAppleEventDescriptor appleEventWithEventClass:'mail'
														  eventID:'mlpg'
												 targetDescriptor:targetDescriptor
														 returnID:kAutoGenerateReturnID
													transactionID:kAnyTransactionID];
	[appleEvent setParamDescriptor:[NSAppleEventDescriptor descriptorWithDescriptorType:'tdta'
																				   data:[webArchive data]]
						forKeyword:'----'];
	[appleEvent setParamDescriptor:[NSAppleEventDescriptor descriptorWithString:aTitle]
						forKeyword:'urln'];
	[appleEvent setParamDescriptor:[NSAppleEventDescriptor descriptorWithString:aURL]
						forKeyword:'url '];
	
	NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:MAIL_BUNDLE_ID];
	NSURL *mailURL = [NSURL URLWithString:path];
	NSDictionary *confDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  appleEvent, NSWorkspaceLaunchConfigurationAppleEvent,
							  nil];
	NSError *error;
	NSRunningApplication *app = [[NSWorkspace sharedWorkspace] launchApplicationAtURL:mailURL
																			  options:NSWorkspaceLaunchDefault
																		configuration:confDict
																				error:&error];
	if (!app) {
		//[[NSApplication sharedApplication] presentError:error];
		[[NSWorkspace sharedWorkspace] openURL:alternateMailToURL];
		return;
	}
}

+ (BOOL)isAppleMailDefault {
	BOOL rtn = NO;
	
	NSString *defaultHandler = (NSString *)LSCopyDefaultHandlerForURLScheme(CFSTR("mailto"));
	if (defaultHandler) {
		if ([defaultHandler isEqualToString:MAIL_BUNDLE_ID])
			rtn = YES;
	} else {
		NSArray *handlers = (NSArray *)LSCopyAllHandlersForURLScheme(CFSTR("mailto"));
		if ([handlers count] == 1 && [[handlers lastObject] isEqualToString:MAIL_BUNDLE_ID])
			rtn = YES;
		[handlers release];
	}
	[defaultHandler release];
	
	return rtn;
}

@end
