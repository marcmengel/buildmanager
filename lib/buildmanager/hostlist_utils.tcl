# force checkin 

proc fill_hosts { w } {
        $w delete 0.0 end
        do_fill_hosts  wputs $w
}

proc file_fill_hosts { file } {
        set fd [open $file "w"]
        do_fill_hosts puts $fd
        close $fd
}

proc wputs { w string } {
        $w insert insert $string
        $w insert insert "\n"
}

proc do_fill_hosts { cmd arg } {
	global host_dat

	set hostlist $host_dat(LIST)
	$cmd $arg  {Host		Flavor		Dir}
	$cmd $arg  {----		------		---}
	foreach h $hostlist {
	    $cmd $arg "$h	$host_dat(h2f,$h)	$host_dat(h2d,$h)"
	}
}

proc change_hosts { w } {
        set result {}
        for {set line 0} {$line < [$w index end]} {incr line} {
	    lappend result [$w get $line.0 "$line.0 lineend"]
        }
        do_change_hosts $result
}

proc file_change_hosts { $file } {
        set fd [open $file "r"]
        set result {}
        while { [fgets $fd line ] } {
	    lappend result $line
        }
        close $fd
        do_change_hosts $result
}

proc do_change_hosts { txt } {
	global host_dat
	foreach h  $host_dat(LIST) {
	    if { [info exists host_dat(h2bw,$h)] } {
		destroy $host_dat(h2bw,$h)
		unset host_dat(h2bw,$h)
            }
	}
       
        set host_dat(LIST) {}
        foreach triple $txt {
	   set h [lindex $triple 0]
           set f [lindex $triple 1]
           set d [lindex $triple 2]
           if { "$h" != "Host" && "$h" != "----" && "$h" != "" } {
	       puts "doing host $h flavor $f dir $d"
	       lappend host_dat(LIST) $h
	       set host_dat(h2f,$h) $f
	       set host_dat(h2d,$h) $d
           }
	}
        updateflavorbuttons .flavors .hosts.f
        repack_hostwindows
}

proc edit_hosts {} {
     hostlist_editor .hostedit
}

proc get_productroot { s } {
     global sw_dat host_dat

     set h $sw_dat(s2h,$s)
     return $host_dat(h2d,$h)
}

proc load_hosts { file w } {
    $w delete 0.0 end
    set fd [open $file "r"]
    while {[ gets $fd line ]} {
	wputs $w $line
    }
    close $fd
}

proc save_hosts { file w } {
    set fd [open $file "w"]
    for {set line 0} {$line < [$w index end]} {incr line} {
	    puts $fd [$w get $line.0 "$line.0 lineend"]
    }
    close $fd
}
