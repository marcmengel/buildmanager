
set vt100_mtags(0) {}
set vt100_mtags(1) bold
set vt100_mtags(2) bold
set vt100_mtags(3) bold
set vt100_mtags(4) bold
set vt100_mtags(5) bold
set vt100_mtags(6) rev
set vt100_mtags(7) rev
set vt100_mtags(8) rev
set vt100line {                                                                                }


proc vt100init { t } {
    global vt100line
    global vt100_taglist

    $t delete 0.0 end
    for { set y 0 } { $y < 23 } { incr y } {
	$t insert end "$vt100line\n"
    }
    $t insert end "$vt100line"
    $t mark set vtcursor 0.1
    set vt100_taglist($t) {}
}

proc vt100pad { t } {
    global vt100line

    for { set l 1 } { $l < 25 } {incr l } {
	set len [string length [$t get "end - $l lines" "end - $l lines lineend"]]
        if { $len < 80 } {
	    $t insert "end - $l lines lineend" [string range $vt100line $len 79]
	}
    }
}

proc vt100string { t string } {
    global vt100_taglist
	
    # assumes string doesn't need to wrap more than once...
    set slen [string length $string]
    set llen [string length [$t get vtcursor {vtcursor lineend}]]
    if { $llen < $slen} {
	if { [$t compare {vtcursor + 1 lines} == end] } {
	    vt100scroll $t
        }
	set string "[string range $string 0 [expr $llen - 1]]\n[string range $string $llen $slen]"
	incr slen
    }
    $t delete vtcursor "vtcursor + $slen chars"
    $t insert vtcursor $string $vt100_taglist($t)
    $t mark set insert vtcursor
    $t see vtcursor
}

proc vt100newline { t } {
    if {[$t compare {vtcursor + 1 lines} == end]} {
        vt100scroll $t
    }
    $t mark set vtcursor "vtcursor +1 lines"
}

proc vt100scroll { t } {
    global vt100line

    $t insert end "\n$vt100line"
}

proc vt100cr { t } { $t mark set vtcursor "vtcursor linestart" }
proc vt100bs { t } { $t mark set vtcursor "vtcursor -1 chars" }
proc vt100bel { t } {
    catch {
	$t configure -background red
	after 100 "$t configure -background {#d9d9d9}"
    }
}

proc vt100esc { t escape first x y letter } {
    global vt100_mtags vt100_taglist

    if { "$y" == "" } { set y 0 }
    if { "$x" == "" } { set x 0 }

    # puts "escape $first $y $x $letter"

    switch "$first$letter" {
    {(B}  { # ignore }
    {[H}	-
    {[f}  {
	    if { $y == 0} { set y 1 }
	    if { $x == 0} { set x 1 }
	    set x [expr $x - 1]
	    # cursor addressing, jump to the top...
	    set ybase [expr int([$t index end]) - 25]
	    $t mark set vtcursor [expr $y + $ybase].$x
	    $t mark set insert vtcursor
	}
    {[A}	{
	    if { $y == 0} { set y 1 }
	    if { [$t compare "vtcursor" > {end - 24 lines}]} {
		$t mark set vtcursor "vtcursor-${x}lines"
            }
	}
    {[B}	{
	    if { $y == 0} { set y 1 }
	    if { [$t compare "vtcursor+${x}lines" < end]} {
		$t mark set vtcursor "vtcursor+${x}lines"
            }
	}
    {[C}	{
	    if { $y == 0} { set y 1 }
	    $t mark set vtcursor "vtcursor+${x}chars"
	}
    {[D}	{
	    if { $y == 0} { set y 1 }
	    $t mark set vtcursor "vtcursor-${x}chars"
	}
    {[J}	{
	    switch $y {
	    0 { $t delete vtcursor end }
	    1 { $t delete 1.0 vtcursor }
	    2 { $t delete 1.0 end }
	    }
	    vt100pad $t
	}
    {[K}	{
	    switch $y {
	    0 { $t delete vtcursor {vtcursor lineend}}
	    1 { $t delete {vtcursor linestart}  lineend}
	    2 { $t delete {vtcursor linestart} {vtcursor lineend}}
	    }
	    vt100pad $t
	}
    {[m}   {
	    if {$y < 1} {
		set vt100_taglist($t) {}
	    } else {
		lappend vt100_taglist($t) $vt100_mtags($y)
		lappend vt100_taglist($t) $vt100_mtags($x)
	    }
	}
    default {
	# puts "unknown escape $escape"
	}
    }
}

proc vt100recv { t string } {
    global vt100_taglist

    if { ![info exists vt100_taglist($t)] } {
	vt100init $t
    }

    set plainpat "(\[^\t\n\r\a\b\x1b\]*)(\[\t\n\r\a\b\x1b\])"
    set escapepat {((\[|O|\()\?*([0-9]*)(;*([0-9]*))([a-zA-Z]))} 
    
    while { [regexp $plainpat $string full before char] } {

	vt100string $t $before

	regsub $plainpat $string {} string

	switch $char {
	"\n"  { vt100newline $t }
	"\r"  { vt100cr $t }
	"\b"  { vt100bs $t }
	"\a"  { vt100bel $t }
	"\x1b" {
		if {[regexp $escapepat $string full escape first y semx x letter]} {
		    regsub $escapepat $string {} string
		    vt100esc $t $escape $first $x $y $letter
		} else  {
		    # puts "unknown escape format $string"
		}
	    }
	}
    }
    catch {
	vt100string $t $string
    }
}
