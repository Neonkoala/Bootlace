# Makefile for iPhone Application for Xcode gcc compiler (SDK Headers)

PROJECTNAME=Bootlace
APPFOLDER=$(PROJECTNAME).app
INSTALLFOLDER=$(PROJECTNAME).app

IPHONE_IP=192.168.0.102

SDKVER=3.0
SDK=/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS$(SDKVER).sdk

CC=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/arm-apple-darwin9-gcc-4.2.1
CPP=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/arm-apple-darwin9-g++-4.2.1
LD=$(CC)

LDFLAGS += -framework CoreFoundation 
LDFLAGS += -framework Foundation 
LDFLAGS += -framework UIKit 
LDFLAGS += -framework CoreGraphics
LDFLAGS += -framework AddressBookUI
LDFLAGS += -framework AddressBook
//LDFLAGS += -framework QuartzCore
//LDFLAGS += -framework GraphicsServices
//LDFLAGS += -framework CoreSurface
//LDFLAGS += -framework CoreAudio
//LDFLAGS += -framework Celestial
//LDFLAGS += -framework AudioToolbox
//LDFLAGS += -framework WebCore
//LDFLAGS += -framework WebKit
//LDFLAGS += -framework SystemConfiguration
//LDFLAGS += -framework CFNetwork
//LDFLAGS += -framework MediaPlayer
//LDFLAGS += -framework OpenGLES
//LDFLAGS += -framework OpenAL
LDFLAGS += -L"$(SDK)/usr/lib"
LDFLAGS += -F"$(SDK)/System/Library/Frameworks"
LDFLAGS += -F"$(SDK)/System/Library/PrivateFrameworks"

CFLAGS += -I"/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/gcc/arm-apple-darwin9/4.2.1/include/"
CFLAGS += -I"$(SDK)/usr/include"
CFLAGS += -I"/Developer/Platforms/iPhoneOS.platform/Developer/usr/include/"
CFLAGS += -I/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator$(SDKVER).sdk/usr/include
CFLAGS += -DDEBUG -std=c99
CFLAGS += -Diphoneos_version_min=3.0
CFLAGS += -F"$(SDK)/System/Library/Frameworks"
CFLAGS += -F"$(SDK)/System/Library/PrivateFrameworks"

CPPFLAGS=$CFLAGS

BUILDDIR=./build/$(SDKVER)
SRCDIR=./Classes
RESDIR=./Resources
OBJS=$(patsubst %.m,%.o,$(wildcard $(SRCDIR)/*.m))
OBJS+=$(patsubst %.c,%.o,$(wildcard $(SRCDIR)/*.c))
OBJS+=$(patsubst %.cpp,%.o,$(wildcard $(SRCDIR)/*.cpp))
OBJS+=$(patsubst %.m,%.o,$(wildcard *.m))
PCH=$(wildcard *.pch)
RESOURCES=$(wildcard $(RESDIR)/*)
NIBS=$(patsubst %.xib,%.nib,$(wildcard *.xib))

all:	$(PROJECTNAME)

$(PROJECTNAME):	$(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^ 

%.o:	%.m
	$(CC) -c $(CFLAGS) $< -o $@

%.o:	%.c
	$(CC) -c $(CFLAGS) $< -o $@

%.o:	%.cpp
	$(CPP) -c $(CPPFLAGS) $< -o $@

%.nib:	%.xib
	ibtool $< --compile $@

dist:	$(PROJECTNAME) $(NIBS)
	rm -rf $(BUILDDIR)
	mkdir -p $(BUILDDIR)/$(APPFOLDER)
	cp -r $(RESOURCES) $(BUILDDIR)/$(APPFOLDER)
	cp Info.plist $(BUILDDIR)/$(APPFOLDER)/Info.plist
	cp Bootlace_ $(BUILDDIR)/$(APPFOLDER)/Bootlace_
	@echo "APPL????" > $(BUILDDIR)/$(APPFOLDER)/PkgInfo
	mv $(NIBS) $(BUILDDIR)/$(APPFOLDER)
	export CODESIGN_ALLOCATE=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/codesign_allocate; ./ldid_intel -S $(PROJECTNAME)
	mv $(PROJECTNAME) $(BUILDDIR)/$(APPFOLDER)

install: dist
	scp -r $(BUILDDIR)/$(APPFOLDER) root@$(IPHONE_IP):/Applications/$(INSTALLFOLDER)
	@echo "Application $(INSTALLFOLDER) installed, please respring iPhone"
	ssh root@$(IPHONE_IP) 'respring'
	ssh root@$(IPHONE_IP) 'chmod +s /Applications/Bootlace.app/Bootlace'

uninstall:
	ssh root@$(IPHONE_IP) 'rm -fr /Applications/$(INSTALLFOLDER); respring'
	@echo "Application $(INSTALLFOLDER) uninstalled, please respring iPhone"

install_respring:
	scp respring_arm root@$(IPHONE_IP):/usr/bin/respring

clean:
	@rm -f $(SRCDIR)/*.o *.o
	@rm -rf $(BUILDDIR)
	@rm -f $(PROJECTNAME)

