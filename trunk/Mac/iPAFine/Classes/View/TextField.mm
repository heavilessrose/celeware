

#import "TextField.h"

@implementation TextField

//
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	if (([theEvent type] == NSKeyDown) && ([theEvent modifierFlags] & NSCommandKeyMask))
	{	
        NSResponder * responder = [[self window] firstResponder];
        
        if ((responder != nil) && [responder isKindOfClass:[NSTextView class]])
        {        
            NSTextView *textView = (NSTextView *)responder;
            NSRange range = [textView selectedRange];
			
            //6 Z, 7 X, 8 C, 9 V
            switch (theEvent.keyCode)
			{
				case 6:
					if ([[textView undoManager] canUndo]) 
					{
						[[textView undoManager] undo];
					}
					break;
					
				case 7:
					if (range.length)
					{
						[textView cut:self];
					}
					break;
					
				case 8:
					if (range.length)
					{
						[textView copy:self];                   
					}
					break;
					
				case 9:
					[textView paste:self];
					break;
					
				case 0:
					[textView selectAll:self];
					break;
					
				default:
					//NSLog(@"%d", theEvent.keyCode);
					return YES;                
			}
		}
	}
	return NO;	
}

@end
