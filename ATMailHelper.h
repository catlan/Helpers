//
//  ATMailHelper.h
//  AP
//
//  Created by Christopher Atlan on 25.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATMailHelper : NSObject {

}

/*! 
	Opens Apple Mails compose new message window with a HTML message.
	@param string The HTML for the new Mail Message
	@param URL The base URL if the HTML requires to load additional resources
	@param aSubject The subject for the new Mail Message
	@param alternateMailToURL If Apple Mail is not the default Mail Client, or something else goes wrong,
	this standard "mailto:?subject=&body=" is called
*/

+ (void)mailHTMLString:(NSString *)string
			   baseURL:(NSURL *)URL
			   subject:(NSString *)aSubject
	alternateMailToURL:(NSURL *)alternateMailToURL;

@end
