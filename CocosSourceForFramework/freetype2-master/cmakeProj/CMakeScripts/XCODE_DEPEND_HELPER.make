# DO NOT EDIT
# This makefile makes sure all linkable targets are
# up-to-date with anything they link to
default:
	echo "Do not invoke directly"

# Rules to remove targets that are older than anything to which they
# link.  This forces Xcode to relink the targets from scratch.  It
# does not seem to check these dependencies itself.
PostBuild.freetype.Debug:
/Users/admin/Documents/HYCloud/sdk/CocosSourceForFramework/freetype2-master/cmakeProj/Debug/libfreetyped.a:
	/bin/rm -f /Users/admin/Documents/HYCloud/sdk/CocosSourceForFramework/freetype2-master/cmakeProj/Debug/libfreetyped.a


PostBuild.freetype.Release:
/Users/admin/Documents/HYCloud/sdk/CocosSourceForFramework/freetype2-master/cmakeProj/Release/libfreetype.a:
	/bin/rm -f /Users/admin/Documents/HYCloud/sdk/CocosSourceForFramework/freetype2-master/cmakeProj/Release/libfreetype.a


PostBuild.freetype.MinSizeRel:
/Users/admin/Documents/HYCloud/sdk/CocosSourceForFramework/freetype2-master/cmakeProj/MinSizeRel/libfreetype.a:
	/bin/rm -f /Users/admin/Documents/HYCloud/sdk/CocosSourceForFramework/freetype2-master/cmakeProj/MinSizeRel/libfreetype.a


PostBuild.freetype.RelWithDebInfo:
/Users/admin/Documents/HYCloud/sdk/CocosSourceForFramework/freetype2-master/cmakeProj/RelWithDebInfo/libfreetype.a:
	/bin/rm -f /Users/admin/Documents/HYCloud/sdk/CocosSourceForFramework/freetype2-master/cmakeProj/RelWithDebInfo/libfreetype.a




# For each target create a dummy ruleso the target does not have to exist
