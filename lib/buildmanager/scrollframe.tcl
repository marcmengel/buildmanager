

proc vscrollframe { w } {
    global tk_version
    bind Vscrollframe <Configure> {

        if { "[info command vscrollframe_cmd]" != "scrollframe_cmd" } {
	    proc vscrollframe_cmd { w cmd {arg {}} {arg2 {}} } {
		global tk_version
		if {$tk_version > 3.6} {
		    set yidx 5
		} else {
		    set yidx 3
		}
		if {! [ winfo exists $w ]} {
		    return
		}
		# figure initial condition
		set h1 [winfo reqheight $w.f]
		set h2 [winfo height $w]
		set off [expr 0 - [lindex [place info $w.f] $yidx]]
		set w1 [winfo reqwidth $w.f]
		if { $h1 < $h2 } {
		    set prcnt 1
		    set base 0
		} else {
		    set prcnt [expr $h2 / $h1.0 ]
		    set base [expr $off / $h1.0 ]
		}
		    
		if { "$cmd" == "Configure" } {
		    # nothing
		} elseif { "$cmd" == "moveto" } {
		    set base $arg
		} elseif { "$cmd" == "scroll" } {
		    if {$arg2 == "unit"} {
			set increment 0.05
		    } else {
			set increment 0.25
		    }
		    set base [expr $base + $increment * $arg]
		} else {
	             set base [expr $cmd / 100.0]
		}
		if { $base < 0 } {
			set base 0
		}
		if { $base + $prcnt > 1 } {
		    set base [expr 1 - $prcnt]
		}
		set off [ expr $base * $h1 ]
		if { $tk_version > 3.6 } {
		    $w.sb set $base [expr $base + $prcnt]
		} else {
		    $w.sb set 100 100 [expr int($base * 100.0)] \
			[expr int(($base + $prcnt)* 100.0)]
		}
		if { $tk_version > 3.6 } {
		    place configure $w.f -x 0 -y [expr 0 - $off]
		} else {
		    place configure $w.f -x 20 -y [expr 0 - $off]
		}
		if { [winfo width $w] <= $w1 } {
		    $w configure -width [expr $w1 + 20]
		} else {
		    place configure $w.f -width [expr [winfo width $w] - 20]
		}
	    }
        }

	vscrollframe_cmd %W Configure
    }
    if {$tk_version > 3.6} {
	bind Vscrollframechild <Configure> {
	    vscrollframe_cmd [winfo parent %W] Configure
	}
    }

    frame $w -width 100 -height 200 -relief sunken -borderwidth 2 \
	-class Vscrollframe
    frame $w.f -width 85 -height 200 -class Vscrollframechild
    scrollbar $w.sb -command  "vscrollframe_cmd $w"  -width 18
    if {$tk_version > 3.6} {
        place configure $w.f -x 0 -y 0 
        place configure $w.sb -relx 1 -x -18 -width 18 -rely 0 -relheight 1
    } else {
	place configure $w.f  -x 20 -y 0
	place configure $w.sb -x 0 -y 0 -width 18 -relheight 1 
    }
}

proc show_in_scrollframe { w } {
    set sf [winfo parent $w]
    set gf [winfo parent $sf]
    set bot [expr [winfo y $w] + [winfo height $w]]
    set offset [expr $bot - [winfo height $gf]]
    set prcnt  [expr $offset * 100 / [winfo height $sf].0]
    puts "y is [winfo y $w] height [winfo height $w] sf height [winfo height $sf]"
    puts "bot is $bot offset is $offset prcnt is $prcnt"
    vscrollframe_cmd $gf $prcnt
}
