
#
# These routines maintain/use the  sw_dat table, which contains:
#   sw_dat(verbose) 		verbosity flag
#   sw_dat(sent_buf,win)	Text sent on win
#   sw_dat(sent_last,win)	Last Text sent (may be echo-ed)
#   sw_dat(rcvd_buf,win)	Chars received
#   sw_dat(logging,win)		flag if this window is being logged 
#   sw_dat(log_fd,win)		file descriptor to log upon
#
# They also maintian
#   sessionlist			List of expect session_id's we're using
#

set sw_dat(verbose) 0
set sw_dat(fixecho) 0

proc sendchars { w string } {
    global sw_dat

    set w $sw_dat(w2w,$w)
    if {"$string" != {} && "$string" != {{}} } {
	exp_send -i $sw_dat(w2s,$w) -- $string
        if { $sw_dat(verbose) } {puts "sent |$string|"}
	append sw_dat(sent_buf,$w) $sw_dat(sent_last,$w)
	set sw_dat(sent_last,$w) $string
	flush_rcvd $w
    }
}

proc rcvchars { w string } {
    global sw_dat

    if { $sw_dat(verbose) } {puts "rcvchars |$string|"}
    if { $sw_dat(fixecho) && "$string" == "$sw_dat(sent_last,$w)" } {
	# echo-ed chars, ignore
    } else {
	if { $sw_dat(verbose) } {puts "doing $w.v.t insert end $string"}

	# collapse carriage-return/newline stuff before inserting
	regsub -all "\r\n" $string "\n" insstring
	regsub -all "\n\r" $string "\n" insstring
	regsub -all "\r" $insstring "\n" insstring

        if { "$string" == "\b" || "$string" == "\b \b" } {
	    $w.v.t delete insert-1c
	} else {
	    $w.v.t mark set insert end
	    $w.v.t insert insert $insstring
	}
	$w.v.t see insert
	append sw_dat(rcvd_buf,$w) $string
	flush_sent $w
    }
}

proc start_logging { w logfile } {
     global sw_dat

     if { ! $sw_dat(logging,$w)} {
	 set sw_dat(log_fd,$w) [open $logfile "w"]
	 set sw_dat(sent_buf,$w) {}
	 set sw_dat(sent_last,$w) {}
	 set sw_dat(rcvd_buf,$w) {}
	 set sw_dat(logging,$w) 1
     }
}

proc stop_logging { w } {
     global sw_dat

     if {$sw_dat(logging,$w)} {
	 flush_sent $w
	 flush_rcvd $w
	 close sw_dat($log_fd,$w)
	 set sw_dat(logging,$w) 0
     }
}

proc flush_rcvd { w } {
     global sw_dat

     if { "$sw_dat(rcvd_buf,$w)" != ""} {
	 if { $sw_dat(logging,$w) }  {
	     puts $log_fd($w) $sw_dat(rcvd_buf,$w)
	 }
	 set sw_dat(rcvd_buf,$w) {}
     }
}

proc flush_sent { w } {
     global sw_dat

     if {$sw_dat(logging,$w) && ("$sw_dat(sent_buf,$w)" != "" || "$sw_dat(sent_last,$w)" != "")} {
	 puts $log_fd($w) $sw_dat(sent_buf,$w)
	 puts $log_fd($w) $sent_last$(w)
     }
     set sw_dat(sent_buf,$w) {}
     set sw_dat(sent_last,$w) {}
}

proc InitExpectText {} {
    foreach sequence [bind Text] {
	set action [bind Text $sequence]
	if { [regexp {Key} $sequence] } {
	    bind ExpectText $sequence {sendchars %W %A}
	} else {
	    bind ExpectText $sequence $action
	}
    }
}

proc sessionwin { w host } {
    global sw_dat sessionlist
    global spawn_id

    sessionwin_gui $w

    set sw_dat(sent_buf,$w) {}
    set sw_dat(sent_last,$w) {}
    set sw_dat(rcvd_buf,$w) {}
    set sw_dat(logging,$w) 0

    InitExpectText
    bindtags $w.v.t [list $w.v.t ExpectText . all]
    # bind $w.v.t <KeyPress>    
    # bind $w.v.t <KeyRelease>  "sendchars %W  %A"
    $w.l1 configure -text "Init"
    $w.l2 configure -text "$host"

    spawn telnet $host
    set sw_dat(w2w,$w) $w
    set sw_dat(w2w,$w.v.t) $w
    set sw_dat(w2s,$w) $spawn_id
    set sw_dat(s2h,$spawn_id) $host
    set sw_dat(s2w,$spawn_id) $w
    set sw_dat(state,$spawn_id) {Init}
    set sw_dat(status,$spawn_id) {Init}

    lappend sessionlist $spawn_id
}


proc setstatus { s txt } {
    global sw_dat

    set w $sw_dat(s2w,$s)
    set sw_dat(status,$s) $txt
    $w.l1 configure -text $txt
}

proc setstate { s txt } {
    global sw_dat

    set w $sw_dat(s2w,$s)
    set sw_dat(state,$s) $txt
    $w.l3 configure -text $txt
}
