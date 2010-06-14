
/*
	bzip2 decompression and compression
	Original Source: <http://cocoa.karelia.com/Foundation_Categories/NSData/bzip2_decompression.m>
	(See copyright notice at <http://cocoa.karelia.com>)
*/

/*"	decompress the file to the given path.  Returns 0 or greater if OK; negative is an error code.  You will need to link against libbz2.a, either the one included in Jaguar, or wrapped and linked into your framework/application bundle.
"*/

#import "bzlib.h"

@implementation bzip2Lib

- (int) decompressBzip2ToPath:(NSString *)inPath;
{
	// First, create all the sub-directories as needed
	NSArray *components = [inPath pathComponents];
	int i;
	int theCount = [components count];

	for (i = 1 ; i < theCount ; i++ )	// DO ALL BUT THE LAST COMPONENT, USE < NOT <=
	{
		NSArray *subComponents = [components subarrayWithRange:
			NSMakeRange(0,i)];
		NSString *subPath = [NSString pathWithComponents:subComponents];
		BOOL isDir;
		BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:subPath isDirectory:&isDir];

		if (!exists)
		{
			BOOL ok = [[NSFileManager defaultManager] createDirectoryAtPath:subPath attributes:nil];
			if (!ok)
			{
				return BZ_IO_ERROR;
			}
		}
	}
	
	int verbosity = 0;
	int small = 0;			// don't use small-memory model
	int bufferSize = 10240;	//	How many bytes to write out at a time

	char *buf = malloc(bufferSize);
	const char *pathName = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:inPath];

	FILE*   	f = fopen ( pathName, "w" );
	if (nil == f)
	{
		return BZ_IO_ERROR;
	}

	// use trio BZ2_bzDecompressInit, BZ2_bzDecompress and BZ2_bzDecompressEnd for decompression.
	int ret = BZ_OK;
	bz_stream strm;
	strm.bzalloc = NULL;
	strm.bzfree = NULL;
	strm.opaque = NULL;
	ret = BZ2_bzDecompressInit ( &strm, verbosity, small );
	if (ret != BZ_OK) return ret;
	strm.next_in = (char *)[self bytes];		// the compressed data
	strm.avail_in = [self length];		// how much to read
	while (BZ_OK == ret)
	{
		strm.next_out = buf;				// buffer to write into
		strm.avail_out = bufferSize;		// how much is available in buffer
		ret = BZ2_bzDecompress ( &strm );

		// Write out the bufs if we had no error.
		if (BZ_OK == ret || BZ_STREAM_END == ret)
		{
			size_t written = fwrite(buf, sizeof(char), strm.next_out - buf, f);
			if (0 == written)
			{
				NSLog(@"Wrote zero bytes");
			}
		}
	}
	fclose(f);
	free (buf);
	BZ2_bzDecompressEnd ( &strm );
	return ret;
}

/* Compress data.  NOT ACTUALLY EVER TESTED;   PLEASE SEND FEEDBACK ON THIS! */

- (NSData *) compressBzip2
{
	NSData *result = nil;
	int blockSize100k = 5; // NOT SURE WHAT BEST VALUE IS.
	int verbosity = 0;		// SHOULD BE ZERO TO BE QUIET.
	int workFactor = 0;		// 0 = USE THE DEFAULT VALUE
	unsigned int sourceLength = [self length];
	unsigned int destLength = 1.01 * sourceLength + 600;	// Official formula, Big enough to hold output.  Will change to real size.
	char *dest = malloc(destLength);
	char *source = (char *) [self bytes];
	int returnCode = BZ2_bzBuffToBuffCompress( dest, &destLength, source, sourceLength, blockSize100k, verbosity, workFactor );

	if (BZ_OK == returnCode)
	{
		result = [NSData dataWithBytesNoCopy:dest length:destLength];
		// Do not free bytes; NSData now owns it.
	}
	else
	{
		NSLog(@"-[NSData decompressBzip2]: error %d returned",returnCode);
		free(dest);
	}
	return result;
}

@end

// BZIP DOCUMENTATION:  ftp://sources.redhat.com/pub/bzip2/docs/manual_3.html