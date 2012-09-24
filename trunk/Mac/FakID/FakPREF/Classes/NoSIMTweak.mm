

#import "FakID.h"
#import "NoSIMTweak.h"


//
void NoSIMTweak()
{
	_Log(@"Enter %@", @"NoSIMTweak");
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:kFakPREFPlist];
	//if (![[dict objectForKey:@"NoSIMTweak"] boolValue])
	{
		NSArray *dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kSpringBoardPath error:nil];
		for (NSString *dir in dirs)
		{
			if ([dir hasSuffix:@".lproj"])
			{
				NSString *path = [kSpringBoardPath stringByAppendingFormat:@"/%@/SpringBoard.strings", dir];
				//NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
				//chmod(path.UTF8String, 666); mode_t
				
				NSError *error = nil;
				//[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithShort:0666], NSFilePosixPermissions/*, NSFileProtectionNone, NSFileProtectionKey*/, nil]
				//								 ofItemAtPath:path error:&error];
				
				_Log(@"Patching NoSIM: %@ -->Error %@", path, error);
				/*NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:path];
				 if (plist)
				 {
				 _Log(@"Patching Plist %d", -1);
				 NSString *str = [plist objectForKey:@"NO_SIM"];
				 [plist setValue:str forKey:@"SEARCHING"];
				 BOOL ret = [plist writeToFile:path atomically:YES];
				 _Log(@"Patching NoSIM Plist:%@ ---> %@", str, (ret ? @"OK" : @"FAILED"));
				 }
				 else*/
				{
					_Log(@"Patching string %d", 0);
					NSStringEncoding encoding = NSUTF8StringEncoding;
					NSMutableString *strings = [NSMutableString stringWithContentsOfFile:path usedEncoding:&encoding error:&error];
					
					if (strings)
					{
						_Log(@"Patching string %d", 1);
						NSRange range = [strings rangeOfString:@"\n\"NO_SIM\" ="];
						if (range.location != NSNotFound)
						{
							_Log(@"Patching string %d", 2);
							range.location += range.length;
							NSUInteger from = range.location;
							range.length = strings.length - range.location;
							range = [strings rangeOfString:@"\";" options:0 range:range];
							if (range.location != NSNotFound)
							{
								_Log(@"Patching string %d", 3);
								range.length = range.location - from;
								range.location = from;
								NSString *value = [strings substringWithRange:range];
								
								range = [strings rangeOfString:@"\n\"SEARCHING\" ="];
								if (range.location != NSNotFound)
								{
									_Log(@"Patching string %d", 4);
									range.location += range.length;
									from = range.location;
									range.length = strings.length - range.location;
									range = [strings rangeOfString:@"\";" options:0 range:range];
									if (range.location != NSNotFound)
									{
										_Log(@"Patching string %d", 5);
										range.length = range.location - from;
										range.location = from;
										[strings replaceCharactersInRange:range withString:value];
										BOOL ret = [strings writeToFile:path atomically:YES encoding:encoding error:&error];
										_Log(@"Patching NoSIM string: %@ ---> %@", value, ((!ret || error) ? error : @"OK"));
									}
								}
							}
						}
					}
				}
				
			}
		}
		
		[dict setObject:[NSNumber numberWithBool:YES] forKey:@"NoSIMTweak"];
		[dict writeToFile:kFakPREFPlist atomically:YES];
	}
}
