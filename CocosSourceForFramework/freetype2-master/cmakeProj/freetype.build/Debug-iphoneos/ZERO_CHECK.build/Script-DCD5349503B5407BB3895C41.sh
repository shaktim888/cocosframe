#!/bin/sh
make -C $SRCROOT/cmakeProj -f $SRCROOT/cmakeProj/CMakeScripts/ZERO_CHECK_cmakeRulesBuildPhase.make$CONFIGURATION OBJDIR=$(basename "$OBJECT_FILE_DIR_normal") all

