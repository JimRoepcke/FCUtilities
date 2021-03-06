//
//  NSString+FCUtilities.m
//  Part of FCUtilities by Marco Arment. See included LICENSE file for BSD license.
//

#import "NSString+FCUtilities.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (FCUtilities)

- (NSString *)fc_URLEncodedString
{
	CFStringRef cs = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) self, NULL, CFSTR("?=&+:;@/$!'()\",*"), kCFStringEncodingUTF8);
	NSString *str = [NSString stringWithString:(__bridge NSString *) cs];
	CFRelease(cs);
	return str;
}

- (NSString *)fc_HTMLEncodedString
{
#if IS_MAC
	CFStringRef cs = CFXMLCreateStringByEscapingEntities(kCFAllocatorDefault, (CFStringRef) self, NULL);
	NSString *str = [NSString stringWithString:(NSString *) cs];
	CFRelease(cs);
	return str;
#else
    NSString *h = [self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    h = [h stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    h = [h stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    h = [h stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    return h;
#endif
}

- (NSString *)fc_summarizeToLength:(int)length withEllipsis:(BOOL)ellipsis
{
	NSString *str = self;
	if ([str length] > length) {
		str = [str substringToIndex:length];

		// Find last space, trim to it
		NSRange offset = [str rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch range:NSMakeRange(0, length)];
		if (offset.location == NSNotFound) offset.location = length;
		str = [NSString stringWithFormat:@"%@%@", [str substringToIndex:offset.location], ellipsis ? @"\xE2\x80\xA6" : @""];
	}
	return str;
}

- (NSString *)fc_substringAfter:(NSString *)needle fromEnd:(BOOL)reverse
{
	NSRange r = [self rangeOfString:needle options:(reverse ? NSBackwardsSearch : 0)];
	if (r.location == NSNotFound) return self;
	return [self substringFromIndex:(r.location + r.length)];
}

- (NSString *)fc_substringBefore:(NSString *)needle fromEnd:(BOOL)reverse
{
	NSRange r = [self rangeOfString:needle options:(reverse ? NSBackwardsSearch : 0)];
	if (r.location == NSNotFound) return self;
	return [self substringToIndex:r.location];
}

- (NSString *)fc_substringBetween:(NSString *)leftCap and:(NSString *)rightCap
{
	return [[self fc_substringAfter:leftCap fromEnd:NO] fc_substringBefore:rightCap fromEnd:NO];
}

- (BOOL)fc_contains:(NSString *)needle
{
	return ([self rangeOfString:needle].location != NSNotFound);
}

- (BOOL)fc_startsWith:(NSString *)needle
{
	if (! needle) return NO;
	NSInteger mylen = [self length], nlen = [needle length];
	if (nlen > mylen) return NO;
	if (nlen == mylen) return [self isEqualToString:needle];
	return [[self substringToIndex:nlen] isEqualToString:needle];
}

- (BOOL)fc_endsWith:(NSString *)needle
{
	if (! needle) return NO;
	NSInteger mylen = [self length], nlen = [needle length];
	if (nlen > mylen) return NO;
	if (nlen == mylen) return [self isEqualToString:needle];
	return [[self substringFromIndex:(mylen - nlen)] isEqualToString:needle];
}

- (NSString *)fc_trimSubstringFromStart:(NSString *)needle
{
	NSInteger nlen = [needle length];
	NSString *ret = self;
	while ([ret fc_startsWith:needle]) ret = [ret substringFromIndex:nlen];
	return ret;
}

- (NSString *)fc_trimSubstringFromEnd:(NSString *)needle
{
	NSInteger nlen = [needle length];
	NSString *ret = self;
	while ([ret fc_endsWith:needle]) ret = [ret substringToIndex:([ret length] - nlen)];
	return ret;
}

- (NSString *)fc_trimSubstringFromBothEnds:(NSString *)needle
{
	return [[self fc_trimSubstringFromStart:needle] fc_trimSubstringFromEnd:needle];
}

- (NSString *)fc_hexString
{
    const char *utf8 = [self UTF8String];
    NSMutableString *hex = [NSMutableString string];
    while ( *utf8 ) [hex appendFormat:@"%02X" , *utf8++ & 0x00FF];
    return [NSString stringWithFormat:@"%@", hex];
}

- (NSString *)fc_MD5Digest
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG) data.length, result);
    data = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];

	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:(data.length * 2)];
    const unsigned char *dataBuffer = data.bytes;
    int i;
    for (i = 0; i < data.length; ++i) {
        [stringBuffer appendFormat:@"%02lx", (unsigned long)dataBuffer[i]];
	}
    return stringBuffer;
}

@end
