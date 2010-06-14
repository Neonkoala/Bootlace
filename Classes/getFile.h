//
//  getFile.h
//  BootlaceV2
//
//  Created by Neonkoala on 14/06/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface getFile : NSObject {
	@private id currentDelegate;
	@private NSMutableData *getFileRequestData;
	@private NSURLConnection *getFileConnection;
	@private NSString *getFileSuggestedName;
	@private NSString *getFilePath;
	@public NSString *getFileURL;
	@public NSString *getFileDir;
	bool getFileWorking;
}

@property (nonatomic, retain) NSMutableData *getFileRequestData;
@property (nonatomic, retain) NSString* getFileURL;
@property (nonatomic, retain) NSString *getFileDir;
@property (nonatomic, retain) NSString *getFileSuggestedName;
@property (nonatomic, retain) NSString *getFilePath;
@property (nonatomic, retain) NSURLConnection *getFileConnection;
@property (nonatomic, assign) bool getFileWorking;

- (void)setDelegate:(id)new_delegate;
- (id)initWithUrl:(NSString *)fileURL directory:(NSString *)dirPath;
- (void)getFileDownload:(id)delegate;
- (void)getFileAbort;

@end


@interface NSObject (getFileDelegate)
- (void)getFileReady:(getFile *)file;

@end
