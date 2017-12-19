Apple2BuildPipeline
===================

A build pipeline for making Apple II software on OS X.
This fork contains updates to work with cc65 V2.16, and a2usbdsk to run built disk images immediately on a real Apple II.

Features:
=========

This project was built based on the one created by [Quinn Dunki](http://quinndunki.com/blondihacks/?p=1904) but it has been expanded to add the following features:

   * Attempts to hide all of the infrastructure which you don't need to modify in a make directory.
   * Supports linking together multiple C and assembly files.  To add a new file to the project, just create a new *.c or *.s file in the project directory.
   * If you change a header file, the right source files will rebuild automatically.  Header file dependencies are generated during the build.
   * Supports all cc65 Apple configurations.  So, if you want to target enhanced Apple IIe's running DOS 3.3, knock yourself out.  Just set the configuration you want in the Makefile and the build will do the right thing to create a disk image for that configuration.
   * On Mac OS X, Virtual II will start when you build and the emulator with execute your program.  This works for all supported cc65 Apple configurations.  Also, it uses a machine configuration which is stored in the make directory in your project.  That way, you can modify the machine configuration to be exactly the config you want to test under.
   * The Mac OS X deliverable is now an installer which will create an Xcode project template.  So, to start a new Apple II project in Xcode, select File->New->Project.  Among the iOS and OS X project templates, you will find the "Apple II Asm Project" and "Apple II C Project" options.  Select either and you will have a new Apple II project ready to go.
   * This fork contains updates to work with cc65 V2.16, and a2usbdsk to run built disk images immediately on a real Apple II.


Mac OS X Installation:
----------------------

In order to use this infrastructure from Mac OS X, follow these instructions:
   1. Install [Xcode from Apple](https://itunes.apple.com/us/app/xcode/id497799835?mt=12&uo=4).  Xcode is generally the most popular app in the Mac App Store in the "Developer Tools" category.  Xcode is free and you do not need to be a registered Apple developer to download and use it, especially if you are building Apple II programs.  I have only tested with Xcode 6 which is the latest version.  It appears as though project templates are a feature introduced in Xcode 4 so the Apple II project template may work with Xcode 4 or 5 but I have not tested them.
   2. Build and Install cc65 v2.16 or later:
<pre>
$ git clone -b 'V2.16' https://github.com/cc65/cc65.git
$ cd cc65
$ make all
$ sudo make install MAKE="make PREFIX=/usr/local prefix=/usr/local SYS=apple2"
</pre>
   3. Install the [Apple II project template](https://github.com/jeremysrand/Apple2BuildPipeline/releases/download/1.6/AppleXcodeTemplate.pkg).
   4. Install and setup [Virtual II](http://www.virtualii.com), or install [a2usbdsk](https://sites.google.com/site/maclcdproc/downloads/a2usbdsk_1.5.tgz).

Your First Project:
-------------------

Everything you need is now installed.  To create a new Apple II project in Xcode:
   1. Start Xcode and create a new project by using File->New->Project...
   2. In the dialog, you will see an "Apple II" option below the OS X section.  Select that and select "Apple II C Project" for a basic C-based project.  Or select "Apple II Asm Project" for a basic assembly project.  Click "Next".
   3. A dialog box with a few text fields will appear.  In product name, put in the name of the Apple II executable you want to build.  Organization Name and Organization Identifier can be anything you want it to be.  Leave Build Tool set to "/usr/bin/make".  Click "Next".
   4. Xcode now prompts you where you want to save your project.  The name of the project will be the product name you already gave.  Pick a good directory for your project.  Your Documents foler is a reasonable option.  Click "Create".
   5. Your project is now ready for you.  If you select Product->Build, it will build and execute the template code in Virtual II.  On your first build, you may be prompted by Mac OS X to install a Java runtime.  Java is required so if you get this prompt, you should install it.  Once Java is installed, go back to Xcode and select Product->Clean and then Product->Build.  Virtual II should launch this time.
   6. At this point everything should work and you should see "HELLO, WORLD!" in the emulator.  Press any key in the emulator to quit the executable and go back to the BASIC prompt.
   7. Review the Makefile and set any options you want.  The file has lots of comments to help you understand the configuration options.
   8. Change main.c (or main.s if you created an assembly project) and write more code in new C or assembly files until you have the program you always wanted to build.  To add new files, select File->New->File.  In the dialog, you will see an Apple II option in the OS X section.  Select that and in there, you will see options to create a new C file or a new Assembly File.  Select the one you want to add the file to your project.  Put the new file in the same directory as Makefile.  You can add assembly files in a C project or add C files in an assembly project.  The only difference between them is the type of the default source file in the project template.

UNIX Installation:
------------------

This build infrastructure can be used in a non-Mac environment.  You need cc65 2.13.3 from ftp://ftp.musoftware.de/pub/uz/cc65/cc65-sources-2.13.3.tar.bz2 and then these commands should work to build the sources:

<pre>
$ tar xvjf cc65-sources-2.13.3.tar.bz2
$ cd cc65-2.13.3
$ make -f make/gcc.mak
$ sudo make -f make/gcc.mak install
</pre>

Once that is done, you can edit the Makefile from the Apple II build pipeline and add new source files as described above.  Be sure to set PGM to the name of your executable in the Makefile.  When you build the project in a non-Mac environment, you should end up with a .dsk file but it will not try to execute that like it would on a Mac.  In theory, other emulators on the Mac or on other host systems could be added to the build infrastructure and feel free to add support for your favourite.

Acknowledgements:
-----------------

Thanks to Quinn Dunki and Carrington Vanston who were instrumental in getting this working.  [Carrington's presentation](http://monsterfeet.com/kfest/) at KansasFest 2014 is where the basic concepts of a better Apple II build environment were demonstrated.  [Quinn built on that](http://quinndunki.com/blondihacks/?p=1904) and included support for automatically starting the program in Virtual II using Applescript.  Without their work, I wouldn't have been able to create this.  Thanks!
