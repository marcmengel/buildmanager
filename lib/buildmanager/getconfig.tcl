
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
}
