proc fill_hosts { w } {
	global host_dat
	set hostlist $host_dat(LIST)
	$w insert insert "Host		Flavor\n"
	$w insert insert "----		------\n"
	foreach h $hostlist {
	    $w insert insert "$h		$host_dat(h2f,$h)\n"
	}
}

proc change_hosts { w } {
	global host_dat
        array set stuff [$w get 3.0 end]
	foreach h  $host_dat(LIST) {
            destroy $host_dat(h2bw,$h)
	    unset host_dat(h2bw,$h)
	}
	puts "new hostlist is [array names stuff]"
	set host_dat(LIST) [array names stuff]
	foreach h [array names stuff] {
	    set host_dat(h2f,$h) $stuff($h)
	}
        updateflavorbuttons .flavors .hosts.f
}

proc edit_hosts {} {
     hostlist_editor .hostedit
}
