
proc cmd_substitute {string s} {
    global product version releasetarget
    global os_dat sw_dat

    set result $string
    set productroot [get_productroot $s]

    set dirname [file dirname $productroot]
    set tail [file tail $productroot]
    regsub -all {%%} $result {_%%_} result
    regsub -all {%D} $result $productroot result
    regsub -all {%d} $result $dirname result
    regsub -all {%T} $result $tail result
    regsub -all {%F} $result $os_dat(s2f,$s) result
    regsub -all {%H} $result $sw_dat(s2h,$s) result
    regsub -all {%W} $result $sw_dat(s2w,$s) result
    regsub -all {%P} $result $product result
    regsub -all {%V} $result $version result
    regsub -all {%R} $result $releasetarget result
    regsub -all {_%%_} $result {%} result
    return $result
}

proc cmd_activelist { string } {
    global sessionlist out_of_the_loop
    global history

     # update command entry widget, history
    .cmd.e delete 0 end
    .cmd.e insert 0 $string
    .cmd.e selection range 0 end
    lappend history $string
    set histslot [llength $history]

    # build session list
    set list {}
    foreach s $sessionlist {
       if { [info exists out_of_the_loop($s)] && $out_of_the_loop($s) } {
	    # nothing
       } else {
	    lappend list $s
       }
    }
    return $list
}

proc cmd_parallel { string {list None} } {
    global sessionlist os_dat global history histslot
    global out_of_the_loop


     # some commands *really* should take turns...

     if { [string match {*ups*declare*} $string] || 
	  [string match {*make*addproduct*} $string]  ||
	  [string match {*make*kits*} $string]  ||
	  [string match {*make*local*} $string]  ||
	  [string match {*upd*product*} $string]  ||
	  [string match {*upd*install*} $string]  } {

         return [cmd_taketurns $string]
     }
    if { "$list" == "None" } {
	set list [cmd_activelist $string]
    }
    foreach s $list {
	set result [cmd_substitute $string $s]
	exp_send -i $s "$result\r"
    } 
} 

proc cmd_taketurns { string {list None} } {
    global pending1 pending2 sessionlist history histslot
    global out_of_the_loop


    if { "$list" == "None"} {
	set list [cmd_activelist $string]
    }
    if { "$list" == "" } {
	return
    }
    set s [lindex $list 0]
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
    bind $w.e <Key-Return> {cmd_taketurns [%W get]}
    bind $w.e <Key-KP_Enter> {cmd_parallel [%W get]}
    bind $w.e <Key-Shift-Return> {cmd_parallel [%W get]}
    }
}

proc cmd_return_parallel {} {
    proc do_cmd_bindings { w } {
    bind $w.e <Key-KP_Enter> {cmd_taketurns [%W get]}
    bind $w.e <Key-Return> {cmd_parallel [%W get]}
    }
}







