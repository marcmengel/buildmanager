
proc getconfiginfo {} {
    global env

    if { ! [info exists env(BUILDMANAGER_DIR)] } {
	set env(BUILDMANAGER_DIR) ~/.buildmanager
    }
    set fd [open "|domainname" "r" ]
    gets $fd domain
    close $fd

    set configfiles [list 	$env(BUILDMANAGER_DIR)/lib/system.cfg	\
    			 	$env(BUILDMANAGER_DIR)/lib/site.cfg	\
    			 	$env(BUILDMANAGER_DIR)/lib/$domain.cfg \
				~/.buildmanagerrc ]

    foreach f $configfiles {
	if { [file exists $f] } {
	    puts "getting config info from $f"
	    uplevel #0 "source $f"
	}
    }
}
