# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  CVS/Build standard makefile template
#  $Id$
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# run commands with bourne shell!
SHELL=/bin/sh

#------------------------------------------------------------------
# DIR is a "proper" name for the current directory 
DIR=$(DEFAULT_DIR)
PREFIX=$(DEFAULT_PREFIX)

#------------------------------------------------------------------
# Variables for ups declaration and setup of product
#
# product name, PRODUCT_DIR environment variable, VERSion, 
# DEPENDency flags for ups, CHAIN name for ups, ups subdirectory name,
# Flavor for ups declares, which is built up from the Operating System,
# Qualifiers, and customization information, which is also used for 
# "cmd addproduct", and finally the distribution file name.
# this section may change in later ups|addproduct incarnations
      UPS_STYLE=old
            PROD=buildmanager
     PRODUCT_DIR=BUILDMANAGER_DIR
            VERS=v1_1
          DEPEND=-u "< expect v5_21 $(FLAVOR)"
  TABLE_FILE_DIR=ups
      TABLE_FILE=action.table
           CHAIN=development
      UPS_SUBDIR=ups
          FLAVOR=$(OS)$(CUST)$(QUALS)
              OS=$(DEFAULT_OS)
           QUALS=
            CUST=$(DEFAULT_CUST)
 ADDPRODUCT_HOST=dcdsv0
DISTRIBUTIONFILE="$(DEFAULT_DISTRIBFILE)"

#------------------------------------------------------------------
# Files to include in Distribution
#
# ADDDIRS is dirs to run "find" in to get a complete list
# ADDFILE is files to pick out by pattern anywhere in the product
# ADDEMPTY is empty directories to include in distribution which would
#	   otherwise be missed
# ADDCMD is a command to run to generate a list of files to include 
#	(one per line) (e.g. 'cd fnal/module; make distriblist')
# LOCAL is destination for local: and install: target
# DOCROOT is destination for html documentation targets
ADDDIRS =.
ADDFILES=
ADDEMPTY=
  ADDCMD=
   LOCAL=/usr/products/$(OS)$(CUST)/$(PROD)/$(VERS)$(QUALS)
 DOCROOT=/afs/fnal/files/docs/products/$(PROD)


#
#------------------------------------------------------------------
# Files that have the version string in them
# this is used by "make setversion" to know what files need
# the version string replaced
VERSIONFILES=Makefile README 

#------------------------------------------------------------------
# this is an *example* of a mythical product with a GNU Configure
# based module "gnuproduct", an X11R6 imake based module "xproduct", 
# and a locally developed product that uses "premake"
# "all" should probably depend on the product directory being set.

all: proddir_is_set
	chmod -R a+r .
	chmod -R g+w .
	chmod 775 bin/buildmanager

clean: 					 # clean up unneeded files	#

spotless: clean

# we indirect this a level so we can customize it for bundle products

declare: $(UPS_STYLE)_declare
undeclare: $(UPS_STYLE)_undeclare
addproduct: $(UPS_STYLE)_addproduct
delproduct: $(UPS_STYLE)_delproduct
autokits: $(UPS_STYLE)_autokits

#---------------------------------------------------------------------------
# 		*** Do not change anything below this line: ***
#     it will go away if you # update the makefile from the templates.
# - - - - - - - - - - - - - cut here - - - - - - - - - - - - -
