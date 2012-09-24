/**
 * This header is generated by class-dump-z 0.1-11o.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 */

#import "SBIcon.h"

@class SBApplication;

@interface SBApplicationIcon : SBIcon {
	SBApplication* _app;
}
-(id)initWithApplication:(id)application;
-(void)dealloc;
-(id)application;
-(id)icon;
-(id)smallIcon;
-(id)displayName;
-(id)displayIdentifier;
-(id)modificationDate:(BOOL)date;
-(BOOL)shouldEllipsizeLabel;
-(id)tags;
-(id)_automationID;
-(BOOL)launchEnabled;
-(void)launch;
-(void)setBadge:(id)badge;
@end

