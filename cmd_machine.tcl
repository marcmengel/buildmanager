proc cmd_machine { machine {list {}} } {
    global sessionlist os_dat global history histslot
    global expect_out sw_dat statepending
    global debug_state

    if { "$list" == "" } {
	set machinelist $sessionlist
    }

    foreach s $machinelist {
	setstate $s init
	foreach triple $machine {
	    set state [lindex $triple 0]
	    set type [lindex $triple 1]
	    set cmd [lindex $triple 2]
	    set statepending($s,$state) [list do_$type $s $state $cmd $machinelist]
	}
    }

    set initcmd [lindex [lindex $machine 0] 2]
    set inittype [lindex [lindex $machine 0] 1]
    if { "$inittype" == "async" } {set inittype all}
    uplevel {#0} [list do_$inittype none init $initcmd $machinelist]
}

proc do_all { s state cmd machinelist } {
    global sw_dat
    global debug_state

    foreach s $machinelist {
	if { "$sw_dat(state,$s)" != "$state" } {
	     if $debug_state {
	         puts "sesson $s is at $sw_dat(state,$s), not $state"
	     }
	     return
	}
    }
    cmd_parallel $cmd $machinelist
}

proc do_turns { s state cmd machinelist } {
    global sw_dat
    global debug_state

    foreach s $machinelist {
	if { "$sw_dat(state,$s)" != "$state" } {
	     if $debug_state {
	         puts "sesson $s is at $sw_dat(state,$s), not $state"
	     }
	     return
	}
    }
    cmd_taketurns $cmd $machinelist
}

proc do_async { s state cmd machinelist } {
	set result [cmd_substitute $cmd $s]
	exp_send -i $s "$result\r"
}

proc update_state {state} {
    global sessionlist os_dat global history histslot
    global expect_out sw_dat statepending

    update_bytes
    set s $expect_out(spawn_id)
    setstate $s $state
    # puts "checking for statepending($s,$state)"
    if { [info exists statepending($s,$state)] } {
        puts "about to do statepending"
	catch $statepending($s,$state)
	unset statepending($s,$state)
    }
}

proc clear_statepending {} {
    global sessionlist os_dat global history histslot
    global expect_out sw_dat statepending

    foreach key [array keys statepending] {
	unset statepending($key)
    }
}
