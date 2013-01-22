#############################################################################################

LAUNCHPAD ASSET MANAGEMENT AND ACTIONSCRIPT 3.0 PROJECT FRAMEWORK FOR MOBILE, DESKTOP AND WEB

#############################################################################################

23rd January 2013
---------------------------------------------------------------------------------------------

This folder should be used for your project mp3 files. In a mobile and desktop project, you
can bring these files in at your own discretion by any method you desire.

For convenience though, the com.thirdsense.sounds.SoundStream class is provided and allows
you to instantly play any mp3 file in this directory as follows:

SoundStream.play( "myAwesomeFreestyle.mp3" );

The path to lib/mp3 is automatically appended to the above call, unless you alter the value
of the static variable 'SoundStream.sound_path' to your preferred relative path. (By default,
the value of this variable is "lib/mp3/")

---------------------------------------------------------------------------------------------
