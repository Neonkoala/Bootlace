//
//  getFile.m
//  BootlaceV2
//
//  Created by Neonkoala on 14/06/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import "getFile.h"


@implementation getFile

@synthesize getFileURL, getFileDir, getFileConnection, getFileRequestData, getFileWorking, getFileSuggestedName, getFilePath;

- (id)initWithUrl:(NSString *)fileURL directory:(NSString *)dirPath {
	self = [super init];
	
	if(self) {
		self.getFileURL = fileURL;
		self.getFileDir = dirPath;
	}
	
	return self;
}


- (void)setDelegate:(id)new_delegate {
    currentDelegate = new_delegate;
}	

- (void)getFileDownload:(id)delegate {
	currentDelegate = delegate;
	
	NSURLRequest *getFileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:getFileURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
	getFileConnection = [[NSURLConnection alloc] initWithRequest:getFileRequest delegate:self];
	
	if(getFileConnection) {
		getFileWorking = YES;
		getFileRequestData = [[NSMutableData data] retain];
	}
}

- (void)getFileAbort {
	if(getFileWorking == YES)
	{
		[getFileConnection cancel];
		[getFileRequestData release];
		getFileWorking = NO;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [getFileRequestData setLength:0];
	
	getFileSuggestedName = [response suggestedFilename];
	self.getFilePath = [getFileDir stringByAppendingPathComponent:getFileSuggestedName];
	[getFileRequestData writeToFile:self.getFilePath atomically:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[getFileRequestData appendData:data];
	
	if([getFileRequestData length] > 2621440) {
		NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:self.getFilePath];
		[fh seekToEndOfFile];
		[fh writeData:self.getFileRequestData];
		[fh closeFile];
			
		[getFileRequestData setLength:0];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [getFileRequestData release];
	
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	getFileWorking = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if(getFileWorking == YES)
	{
		//Write leftover data to file		
		NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:self.getFilePath];
		[fh seekToEndOfFile];
		[fh writeData:self.getFileRequestData];
		[fh closeFile];
		
		[getFileRequestData release];
		
		if ([currentDelegate respondsToSelector:@selector(getFileReady:)])
		{
			// Call the delegate method and pass ourselves along.
			[currentDelegate getFileReady:self];
		}
		
		getFileWorking = NO;
	}	
}

- (void)dealloc 
{
    [getFileConnection release];
	[getFileURL release];
	[super dealloc];
}

@end
