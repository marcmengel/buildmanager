
proc cmd_substitute {string s} {
    global product version releasetarget
    global os_dat sw_dat

    set result $string
    set productroot [productroot $os_dat(s2f,$s)]
    set dirname [file dirname $productroot]
    set tail [file tail $productroot]
    regsub -all {%D} $result $productroot result
    regsub -all {%d} $result $dirname result
    regsub -all {%T} $result $tail result
    regsub -all {%F} $result $os_dat(s2f,$s) result
    regsub -all {%H} $result $sw_dat(s2h,$s) result
    regsub -all {%W} $result $sw_dat(s2w,$s) result
    regsub -all {%P} $result $product result
    regsub -all {%V} $result $version result
    regsub -all {%R} $result $releasetarget result
    return $result
}

proc cmd_parallel { string {list {}} } {
    global sessionlist os_dat global history histslot
    global out_of_the_loop

    .cmd.e delete 0 end
    .cmd.e insert 0 $string
    .cmd.e selection range 0 end
    lappend history $string
    set histslot [llength $history]
    # puts "history is $history"
    if { "$list" == "" } {
	set list $sessionlist
    }
    foreach s $list {
        if { ![info exists out_of_the_loop($s)] || !$out_of_the_loop($s)} {
	    set result [cmd_substitute $string $s]
	    exp_send -i $s "$result\r"
	}
    }
}

proc cmd_taketurns { string {list {xxxxxxxxxx}} } {
    global pending1 pending2 sessionlist history histslot
    global out_of_the_loop

    if { "$list" == "$sessionlist" } {
	.cmd.e delete 0 end
	.cmd.e insert 0 $string
	.cmd.e selection range 0 end
        lappend history $string
        set histslot [llength $history]
        # puts "history is $history"
    }
    if { "$list" == "xxxxxxxxxx" } {
	set list $sessionlist
    }
    if { "$list" == "" } {
	return
    }
    set s [lindex $list 0]
    while { [info exists out_of_the_loop($s)] && $out_of_the_loop($s) } {
	set list [lrange $list 1 end]
        set s [lindex $list 0]
        if { "$list" == "" } {
 	    return
        }
    }
    set list [lrange $list 1 end]
    set pending1($s) [list cmd_taketurns $string $list]
    set result [cmd_substitute $string $s]
    exp_send -i $s "$result\r"
}

proc cmd_previous {} {
    global history histslot

    set histslot [ expr $histslot - 1 ]
    .cmd.e delete 0 end
    .cmd.e insert 0 [lindex $history $histslot]
}

proc cmd_next {} {
    global history histslot
    
    incr histslot
    .cmd.e delete 0 end
    .cmd.e insert 0 [lindex $history $histslot]
}

proc cmd_return_takesturns {} {
    proc do_cmd_bindings { w } {
    bind $w.e <Key-Return> {cmd_taketurns [%W get] $sessionlist}
    bind $w.e <Key-KP_Enter> {%W selection range 0 end; cmd_parallel [%W get]}
    }
}

proc cmd_return_parallel {} {
    proc do_cmd_bindings { w } {
    bind $w.e <Key-KP_Enter> {cmd_taketurns [%W get] $sessionlist}
    bind $w.e <Key-Return> {%W selection range 0 end; cmd_parallel [%W get]}
    }
}

