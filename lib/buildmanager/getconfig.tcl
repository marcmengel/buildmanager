
proc getconfiginfo {} {
    global env

    if { ! [info exists env(BUILDCONFIG_DIR)] } {
	set env(BUILDCONFIG_DIR) ~/.buildmanager
    }
    set fd [open "|domainname" "r" ]
    gets $fd domain
    close $fd

    set configfiles [list 	$env(BUILDCONFIG_DIR)/lib/system.cfg	\
    			 	$env(BUILDCONFIG_DIR)/lib/site.cfg	\
    			 	$env(BUILDCONFIG_DIR)/lib/$domain.cfg \
				~/.buildmanagerrc ]

    foreach f $configfiles {
	if { [file exists $f] } {
	    puts "getting config info from $f"
	    uplevel #0 "source $f"
	}
    }

    # ----------------------------------------------

    #
    # Now if its an older config, it doesn't define host_dat(h2d,host)
    # but does have a proc productroot defined, so use one to
    # define the other
    #
    if { "[info command productroot]" == "productroot" } {
	global host_dat product version
	set save_prod $product
	set save_vers $version

	set product %P
	set version %V
	foreach host $host_dat(LIST) {
            if { ![info exists host_dat(h2d,$host)] } {
                 set flavor $host_dat(h2f,$host)
                 set path [productroot $flavor]
		 regsub -all {[+.]} $flavor {\\&} flavor
		 regsub -all $flavor $path {%F} path
                 set host_dat(h2d,$host) $path
            }
        }
	set product $save_prod 
	set version $save_vers 
    }
}
