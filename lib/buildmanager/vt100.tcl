
proc vt100init { t } {
    global vt100_taglist
    $t delete 1.0 end
    $t mark set vt100cursor 1.0
    $t mark set vt100origin 1.0
    set vt100_taglist($t) {}
}


set vt100_mtags(0) {}
set vt100_mtags(1) bold
set vt100_mtags(2) bold
set vt100_mtags(3) bold
set vt100_mtags(4) bold
set vt100_mtags(5) bold
set vt100_mtags(6) rev
set vt100_mtags(7) rev
set vt100_mtags(8) rev
set vt100seenew 1



proc vt100string { t string } {
    global vt100_taglist
    global vt100seenew
	
    set slen [string length $string]
    set llen [string length [$t get vt100cursor {vt100cursor lineend}]]
    if { $llen < $slen } { set slen $llen }
    $t delete vt100cursor "vt100cursor + $slen chars"
    $t insert vt100cursor $string $vt100_taglist($t)
    $t mark set insert vt100cursor
    if {$vt100seenew} {
	 $t see vt100cursor
    }
}

proc vt100newline { t } {
    if {[$t compare {vt100cursor + 1 lines} == end]} {
        vt100scroll $t
    } else {
	vt100move rel $t 0 1
    }
}

proc vt100scroll { t } {
    global vt100line
    global vt100seenew

    $t insert end "\n"
    $t mark set vt100cursor end
    $t mark set vt100origin "end -24 lines linestart"
    # puts "vt100scroll vt100origin: [$t index vt100origin] end: [$t index end]"
    if {$vt100seenew} {
	 $t see end
    }
}

proc vt100cr { t } { $t mark set vt100cursor "vt100cursor linestart" }

proc vt100bs { t } { 
    set i [$t index vt100cursor]

    if { int($i) == $i } {
	# sometimes we're at the zeroth char of the next line???
	$t mark set vt100cursor "vt100cursor -1 chars" 
    }
    $t mark set vt100cursor "vt100cursor -1 chars" 
}

proc vt100bel { t } {
    catch {
        set color [$t cget -background]
	$t configure -background red
	after 100 "$t configure -background $color"
    }
}

proc vt100esc { t escape first x y letter } {
    global vt100_mtags vt100_taglist

    if { "$y" == "" } { set y 0 }
    if { "$x" == "" } { set x 0 }

    # puts "escape $first $y $x $letter"

    switch "$first$letter" {
    {(B}  { # ignore }
    {[@}  { 
 	    #insert...

	    set save [$t index vt100cursor]
	    if { $y == 0} { set y 1 }
	    set char [$t get vt100cursor "vt100cursor + $y chars" ]
            $t insert vt100cursor "$char"
            $t mark set vt100cursor $save
          }
    {[L}  {
	    if { $y == 0} { set y 1 }
	    set save1 [$t index vt100cursor]
	    set save2 [$t index vt100origin]
	    $t insert vt100cursor "\n"
            $t mark set vt100cursor $save1
            $t mark set vt100origin $save2
          }
    {[H}	-
    {[f}  {
	    if { $y == 0} { set y 1 }
	    if { $x == 0} { set x 1 }
            vt100move abs $t $x $y
	}
    {[A}	{
	    if { $y == 0} { set y 1 }
	    vt100move rel $t 0 -${y}
	}
    {[B}	{
	    if { $y == 0} { set y 1 }
	    vt100move rel $t 0 ${y}
	}
    {[C}	{
	    if { $y == 0} { set y 1 }
            vt100move rel $t $y 0
	}
    {[D}	{
	    if { $y == 0} { set y 1 }
            vt100move rel $t -$y 0
	}
    {[J}	{
	    set save [$t index vt100origin]
	    switch $y {
	    0 { 
		$t delete vt100cursor end 
		vt100pad $t
              }
	    1 { 
 		$t delete vt100origin vt100cursor 
		vt100pad $t
              }
	    2 { 
		$t delete $save end 
		vt100pad $t
	      }
	    }
	    $t mark set vt100cursor $save
	    $t mark set vt100origin $save
	}
    {[K}	{
	    switch $y {
	    0 { $t delete vt100cursor {vt100cursor lineend}}
	    1 { $t delete {vt100cursor linestart}  lineend}
	    2 { $t delete {vt100cursor linestart} {vt100cursor lineend}}
	    }
	}
    {[m}   {
	    if {$y < 1} {
		set vt100_taglist($t) {}
	    } else {
		lappend vt100_taglist($t) $vt100_mtags($y)
		lappend vt100_taglist($t) $vt100_mtags($x)
	    }
	}
    {[P}	{
	    if { $y == 0} { set y 1 }
	    $t delete vt100cursor "vt100cursor +$y chars"
        }
    default {
	# puts "unknown escape $escape"
	}
    }
    $t mark set vt100origin "vt100origin linestart"
}


proc vt100recv { t string } {
    global vt100_taglist

    if { ![info exists vt100_taglist($t)] } {
	vt100init $t
    }

    set plainpat "(\[^\t\n\r\a\b\x1b\x0f\]*)(\[\t\n\r\a\b\x1b\x0f\])"
    set escapepat {((\[|O|\()\?*([0-9]*)(;*([0-9]*))([a-zA-Z@]))} 
    
    while { [regexp $plainpat $string full before char] } {

        if { "$before" != "" } {
	    vt100string $t $before
        }

	regsub $plainpat $string {} string

	switch $char {
	"\x0f"  { # ignore }
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

set vt100lines {



























}
set vt100spaces {                                                                                   }

proc vt100move { relabs t x y } {
    global vt100spaces vt100lines

    $t mark set vt100origin "vt100origin linestart"
    # puts "in  vt100move { relabs: $relabs x: $x y: $y }  vt100origin: [$t index vt100origin] end: [$t index end]"

    if { $relabs == "rel" } {
        regexp {([0-9]*)\.([0-9]*)} [$t index vt100cursor] full by bx
        set x [expr $x + $bx]
        set y [expr $y + $by]
    } else { 
	regexp {([0-9]*)\.([0-9]*)} [$t index vt100origin] full by bx
	set x [expr $x + $bx - 1]
	set y [expr $y + $by - 1]
    }

    #
    # pad lines and spaces needed to get to coordinates
    #
    set diff [expr int( $y - [$t index end])]
    if { $diff > 0 } {
        $t insert end [string range $vt100lines 1 $diff]
    }

    set diff [expr $x - [string length [$t get $y.0 "$y.0 lineend"]]]
    if { $diff > 0 } {
        $t insert "$y.0 lineend" [string range $vt100spaces 1 $diff]
    }

    $t mark set vt100cursor $y.$x
    $t mark set insert vt100cursor

    # puts "out vt100move x: $x y: $y vt100origin: [$t index vt100origin] end: [$t index end]"
}

proc vt100pad { t } {
    global vt100lines
    global vt100seenew

    set save1 [$t index vt100cursor]
    set save2 [$t index vt100origin]
    set lines [expr int( 25 - ([$t index end] - [$t index vt100origin]))]
    $t insert end [string range $vt100lines 1 $lines]
    $t mark set vt100cursor $save1
    $t mark set vt100origin $save2
    if {$vt100seenew} {
	 $t see end
    }
}
