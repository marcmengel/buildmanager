
proc set_everything_state { win state } {
    if { [winfo class $win] != "Text" } {
        catch {$win configure -state $state} 
	catch {$win configure -foreground [$win cget -foreground]} 
    }
    foreach kid [winfo children $win] {
	set_everything_state $kid $state
    }
}

proc newloginsessions { newsessions } {
    global logname password expect_out timeout
    global promptre
    global sessionlist sw_dat os_dat
    global env
    global logsessions

    set_everything_state . disabled

    if {[info exists os_dat(ENVVARS)]} {
	foreach var $os_dat(ENVVARS) {
	    if { ![info exists env($var)] } {
		puts "buildmanager: warning, $var not set to pass through!"
	    }
	}
    }

    # build up sequence of commands to type in

    foreach s $newsessions {
        set w $sw_dat(s2w,$s)
        set flavor $os_dat(w2f,$w)
	set cmdlist($s) {}
	lappend cmdlist($s) "exec /bin/sh"
	lappend cmdlist($s) "PS1='<$sw_dat(s2h,$s)> '"
        if {[info exists os_dat(INIT_COMMANDS)]} {
	    foreach cmd $os_dat(INIT_COMMANDS) { 
		lappend cmdlist($s) $cmd
	    }
	}
        if {[info exists os_dat(PATH,$flavor)]} {
  	    lappend cmdlist($s) "PATH=$os_dat(PATH,$flavor):\$PATH; export PATH"
	}

	if {[info exists os_dat(ENVVARS)]} {
	    foreach var $os_dat(ENVVARS) {
		if { [info exists env($var)] } {
		    lappend cmdlist($s)  "$var='$env($var)'; export $var"
		}
	    }
	}
	if {[info exists os_dat(COMMANDS)]} {
	    foreach cmd $os_dat(COMMANDS) {
		lappend cmdlist($s) $cmd
	    }
	}
	if {[info exists os_dat(PLAT_COMMANDS,$flavor)]} {
	    foreach cmd $os_dat(PLAT_COMMANDS,$flavor) {
		lappend cmdlist($s) $cmd
	    }
	}
	lappend cmdlist($s) "set -x"
	set ncmds($s) [llength $cmdlist($s)]
	set curcmd($s) 0
	set logfails($s) 0
	setstatus $s Login
    }

    set logfail {([Ii]ncorrect|[Uu]nkown|[Uu]nable)}
    set timesasked 0
    
    set logsessions $newsessions
    set loginfailed 1

    while {[llength $logsessions] > 0} {
        set loginfailed 0
	expect {
	    -i logsessions -re {ast login: } {
		    update_bytes
		    exp_continue 
	    }
	    -i logsessions -re {ogin: $} 	 { 
		    set s $expect_out(spawn_id)
		    update_bytes
		    exp_send -i $s "$logname\r"
		    exp_continue 
	    }
	    -i logsessions -re {word: ?$} 	 { 
		    set s $expect_out(spawn_id)
		    update_bytes
		    exp_send -i $s "$password\r"
		    exp_continue 
	    }
	    -i logsessions -re $logfail	 {
		update_bytes
		set s $expect_out(spawn_id)
		set host $sw_dat(s2h,$s)


		set loginfailed $s
	    }
	    -i logsessions -re $promptre	 { 

		set s $expect_out(spawn_id)
		update_bytes
		exp_send -i $s "[lindex $cmdlist($s) $curcmd($s)]\r"
		setstatus $s "Setup - $curcmd($s)"
		incr curcmd($s)
		if { $curcmd($s) > $ncmds($s) } {
		    set index [lsearch -exact $logsessions $s]
		    set logsessions [lreplace $logsessions $index $index]
		}
		if {[llength $logsessions] > 0} {
		    exp_continue
		}
	    }
	    -i logsessions -re "\[\r\n\]+"	{ 
		    update_bytes
		    exp_continue
	    }
	    -i logsessions timeout	 { 
		    exp_continue
	    }
	    -i logsessions eof	 { 
		set s $expect_out(spawn_id)
		set host $sw_dat(s2h,$s)

		puts "lost connection on host $host"
		set index [lsearch -exact $logsessions $s]
		set logsessions [lreplace $logsessions $index $index]
		drop_session $s
		if {[llength $logsessions] > 0} {
		    exp_continue
		}
	    }
	}
	if {$loginfailed != 0 } {
	    set s $loginfailed
	    incr logfails($s)

	    if {$logfails($s) < 4 } {

		if {$logfails($s) > $timesasked } {
		    incr timesasked
		    sleep 1
		    update
	            getlogininfo "Login failed on host $host, please re-enter login info"
		}

	    } else {
		puts "login failed repeatedly on host $host"
                set index [lsearch -exact $logsessions $s]
                set logsessions [lreplace $logsessions $index $index]
		drop_session $s
	    }
	}
    }
    set_everything_state . enabled
}

proc getlogininfo { reason } {
     global logname password
     global loginok
     global login_reason
     global logininfoflag

     set login_reason $reason
     if { "passwd_popup" == [info command passwd_popup]} {
	 update
	 passwd_popup .pop
	 tkwait window .pop
     } else {
	 puts $reason
	 puts -nonewline "login: "
	 flush stdout
	 gets stdin logname
	 exec stty -echo
	 puts -nonewline "password: "
	 flush stdout
	 gets stdin password
	 exec stty echo
	 puts ""
	 flush stdout
    }
    set loginok 1
}

