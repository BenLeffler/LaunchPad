LaunchPad Project Structure
===========================

The lib folder here-in contained is the recommended structure for a LaunchPad based project.

The structure however is entirely configurable as asset paths can be altered in the here-in contained config.xml file

The base swf/apk/ipa by default will search for the relative path to the file lib/xml/config.xml in the initialization process, however in a web environment you are able to point the swf to a different location for this file by embedding with a flashvar "libpath" that appends its value to the front of the "lib/xml/config.xml" value in the project bones.

For questions, contact ben@3rdsense.com