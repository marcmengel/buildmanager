
#
# These routines maintain/use the  sw_dat table, which contains:
#   sw_dat(verbose) 		verbosity flag
#   sw_dat(sent_buf,win)	Text sent on win
#   sw_dat(sent_last,win)	Last Text sent (may be echo-ed)
#   sw_dat(rcvd_buf,win)	Chars received
#   sw_dat(logging,win)		flag if this window is being logged 
#   sw_dat(log_fd,win)		file descriptor to log upon
#   sw_dat(w2s,win)		session id attached to win
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
    global taglist

    catch {$w.v.t mark set insert end}
    if { ![info exists taglist] } { set taglist {} }
    if { $sw_dat(verbose) } {puts "rcvchars |$string|"}
    if { $sw_dat(fixecho) && "$string" == "$sw_dat(sent_last,$w)" } {
	# echo-ed chars, ignore
    } else {
	if { $sw_dat(verbose) } {puts "doing $w.v.t insert end $string"}

	# collapse carriage-return/newline stuff before inserting
	regsub -all "\[\r\n\]+" $string "\n" string

	# stty erase with space setting
	while { [ regsub "^\b \b" $string {} string ] } {
	     catch {$w.v.t delete insert-1c}
	}
	if { [ regsub "\a" $string {} string ] } {
	    catch {
		    $w.v.t configure -background red
		    after 100 "$w.v.t configure -background {#d9d9d9}"
	    }
	}
	while { [ regsub "\a" $string {} string ] } {
	}
        # eat overstrikes
        while { [regsub -all "\[^\b\]\b" $string {} string ] } {
        }
	while { [ regsub "^\b" $string {} string ] } {
	     catch {$w.v.t mark set insert insert-1c}
	}
       
        set escapepat "(\[^\x1b\]*)(\x1b\\\[\[0-9;\]*\[a-zA-z\])" 
	while {  [ regexp $escapepat $string full before escape ] } {
            regsub "\x1b" $escape {<ESC>} printit
            # puts "saw escape $printit"

	    catch {
		$w.v.t insert insert $before $taglist
            }
            regsub $escapepat $string {} string
	    if { $escape == "\x1b\[0m" || $escape == "\x1b\[m" } {
	        set taglist {}
	    }
	    if { $escape == "\x1b\[1m" } {
		    lappend taglist bold
	    }
	    if { $escape == "\x1b\[4m" } {
	    }
	    if { $escape == "\x1b\[24;1H" } {
		$w.v.t mark set insert {insert linestart}
	    }
	    if { $escape == "\x1b\[K" } {
		$w.v.t delete insert {insert lineend}
	    }
	    if { $escape == "\x1b\[7m" } {
		    lappend taglist rev
	    }
	}
	catch {
	    $w.v.t insert insert $string $taglist
	    $w.v.t see end
	}
	append sw_dat(rcvd_buf,$w) $string
	flush_sent $w
    }
}

proc toggle_logging { w } {
     global sw_dat 

     if { !$sw_dat(logging,$w)} {
	start_logging $w  "$sw_dat(s2h,$sw_dat(w2s,$w)).log"
     } else {
	stop_logging $w 
     }
}

proc toggle_cmd { w } {
     global sw_dat 
     global out_of_the_loop

     set s $sw_dat(w2s,$w)
     if {[info exists out_of_the_loop($s)] && $out_of_the_loop($s) } {
         set out_of_the_loop($s) 0
     } else {
         set out_of_the_loop($s) 1
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
	 close $sw_dat(log_fd,$w)
	 set sw_dat(logging,$w) 0
     }
}

proc flush_rcvd { w } {
     global sw_dat

     if { "$sw_dat(rcvd_buf,$w)" != ""} {
	 if { $sw_dat(logging,$w) }  {
	     puts -nonewline $sw_dat(log_fd,$w) $sw_dat(rcvd_buf,$w)
	 }
	 set sw_dat(rcvd_buf,$w) {}
     }
}

proc flush_sent { w } {
     global sw_dat

     if {$sw_dat(logging,$w) && ("$sw_dat(sent_buf,$w)" != "" || "$sw_dat(sent_last,$w)" != "")} {
	 puts -nonewline $sw_dat(log_fd,$w) $sw_dat(sent_buf,$w)
	 # puts -nonewline $sw_dat(log_fd,$w) $sw_dat(sent_last,$w)
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

    # control c needs to work!
    bind ExpectText <Control-Key-c> 	{sendchars %W "\x003"}

    # xterm mouse button 2 emulation
    #
    bind ExpectText <<Paste>> 		{sendchars %W [selection get]}
    bind ExpectText <ButtonRelease-2>	{sendchars %W [selection get]}

    # vt100 keypad mode emulation
    #
    bind ExpectText <Key-BackSpace> 	{sendchars %W "\x7f"}
    bind ExpectText <Key-Num_Lock> 	{sendchars %W "\x1bOP"}
    bind ExpectText <Key-Up>		{sendchars %W "\x1b\[A"}
    bind ExpectText <Key-Down>		{sendchars %W "\x1b\[B"}
    bind ExpectText <Key-Right>		{sendchars %W "\x1b\[C"}
    bind ExpectText <Key-Left>		{sendchars %W "\x1b\[D"}
    bind ExpectText <KP_Divide>		{sendchars %W "\x1b\[OQ"}
    bind ExpectText <KP_Multiply>	{sendchars %W "\x1b\[OR"}
    bind ExpectText <KP_Subtract>	{sendchars %W "\x1b\[OS"}
    bind ExpectText <KP_Add>		{sendchars %W "\x1b\[Om"}
    bind ExpectText <Pause>		{sendchars %W "\x1b\[Ol"}
    bind ExpectText <Print>		{sendchars %W "\x1b\[28~"}
    bind ExpectText <Cancel>		{sendchars %W "\x1b\[29~"}
    bind ExpectText <KP_0>		{sendchars %W "\x1bOp" }
    bind ExpectText <KP_1>		{sendchars %W "\x1bOq" }
    bind ExpectText <KP_2>		{sendchars %W "\x1bOr" }
    bind ExpectText <KP_3>		{sendchars %W "\x1bOs" }
    bind ExpectText <KP_4>		{sendchars %W "\x1bOt" }
    bind ExpectText <KP_5>		{sendchars %W "\x1bOu" }
    bind ExpectText <KP_6>		{sendchars %W "\x1bOv" }
    bind ExpectText <KP_7>		{sendchars %W "\x1bOw" }
    bind ExpectText <KP_8>		{sendchars %W "\x1bOx" }
    bind ExpectText <KP_9>		{sendchars %W "\x1bOy" }
    bind ExpectText <KP_Decimal>	{sendchars %W "\x1bOn" }
    bind ExpectText <KP_Insert>		{sendchars %W "\x1b\[1~" }
    bind ExpectText <KP_Home>		{sendchars %W "\x1b\[2~" }
    bind ExpectText <KP_Prior>		{sendchars %W "\x1b\[3~" }
    bind ExpectText <KP_Delete>		{sendchars %W "\x1b\[4~" }
    bind ExpectText <KP_End>		{sendchars %W "\x1b\[5~" }
    bind ExpectText <KP_Next>		{sendchars %W "\x1b\[6~" }
    bind ExpectText <KP_Enter>		{sendchars %W "\x1bOM" }
    bind ExpectText <F1>		{sendchars %W "\x1b\[17~" }
    bind ExpectText <F2>		{sendchars %W "\x1b\[18~" }
    bind ExpectText <F3>		{sendchars %W "\x1b\[19~" }
    bind ExpectText <F4>		{sendchars %W "\x1b\[20~" }
    bind ExpectText <F5>		{sendchars %W "\x1b\[21~" }
    bind ExpectText <F6>		{sendchars %W "\x1b\[23~" }
    bind ExpectText <F7>		{sendchars %W "\x1b\[24~" }
    bind ExpectText <F8>		{sendchars %W "\x1b\[25~" }
    bind ExpectText <F9>		{sendchars %W "\x1b\[26~" }
    bind ExpectText <F10>		{sendchars %W "\x1b\[28~" }
    bind ExpectText <F11>		{sendchars %W "\x1b\[29~" }
    bind ExpectText <F12>		{sendchars %W "\x1b\[31~" }
}

proc sessionwin { w host } {
    global sw_dat sessionlist
    global spawn_id

    spawn telnet $host
    set sw_dat(w2w,$w) $w
    set sw_dat(w2w,$w.v.t) $w
    set sw_dat(w2s,$w) $spawn_id
    set sw_dat(s2h,$spawn_id) $host
    set sw_dat(s2w,$spawn_id) $w
    set sw_dat(state,$spawn_id) {Init}
    set sw_dat(status,$spawn_id) {Init}

    lappend sessionlist $spawn_id

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

}


proc setstatus { s txt } {
    global sw_dat

    set w $sw_dat(s2w,$s)
    set sw_dat(status,$s) $txt
    if { [winfo exists $w.l1] } {
        $w.l1 configure -text $txt
    }
}

proc setstate { s txt } {
    global sw_dat

    set w $sw_dat(s2w,$s)
    set sw_dat(state,$s) $txt
    $w.l3 configure -text $txt
}
