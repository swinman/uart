#!/bin/bash

# use
# $ source set_environ.sh
# attempt to run synplify_pro ... doesn't work
#export LM_LICENSE_FILE=~/tools/lscc/iCEcube2.2014.04/license.dat
#~/tools/lscc/iCEcube2.2014.04/synpbase/bin/synplify_pro

export ICEDIR=$toolsdir/lscc/iCEcube2.2014.04

export LD_LIBRARY_PATH=
export LD_LIBRARY_PATH=$ICEDIR/LSE:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ICEDIR/LSE/bin/lin:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ICEDIR/sbt_backend/lib/linux/opt:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ICEDIR/sbt_backend/bin/linux/opt/synpwrap:$LD_LIBRARY_PATH

export FOUNDRY=$ICEDIR/LSE
export SYNPLIFY_PATH=$ICEDIR/synpbase
export SBT_DIR=$ICEDIR/sbt_backend

export DIAMOND_DIR=/usr/local/diamond/3.2_x64
export PATH=$PATH:$DIAMOND_DIR/bin/lin64:$DIAMOND_DIR/ispfpga/bin/lin64

alias synpwrap=$ICEDIR/sbt_backend/bin/linux/opt/synpwrap/synpwrap
alias synthesis=$ICEDIR/LSE/bin/lin/synthesis
alias sbrouter=$ICEDIR/sbt_backend/bin/linux/opt/sbrouter
alias edifparser=$ICEDIR/sbt_backend/bin/linux/opt/edifparser
alias sbtplacer=$ICEDIR/sbt_backend/bin/linux/opt/sbtplacer

#TAGHL=~/vimfiles/bundle/taghighlight/plugin/TagHighlight/TagHighlight.py
TAGHL=~/.vim/bundle/taghighlight/plugin/TagHighlight/TagHighlight.py
ctags-exuberant -R
python $TAGHL --ctags-file tags --source-root .

#$ICEDIR/sbt_backend/bin/linux/opt/synpwrap/synpwrap -prj proj/stopsen_syn.prj -log icelog.log

#$ICEDIR/LSE/bin/lin/synthesis –f proj/stopsen_lse.prj

#tclsh iCEcube2_flow.tcl
