proc historylist_popup { w } {

# ---------------- Toplevel  $w ---------------------
if {![winfo exists $w]} {toplevel $w}
set x [expr [winfo rootx [winfo parent $w]] - 480]
set y [expr 15 + [winfo rooty [winfo parent $w]]]
wm minsize $w 1 1
wm maxsize $w 1265 994
wm title $w {t9}
wm focusmodel $w passive
wm overrideredirect $w 1
wm geometry $w 500x200+$x+$y

# ---------------- Frame  $w.v10 ---------------------
if {![winfo exists $w.v10]} {frame $w.v10}
 $w.v10 configure -borderwidth "4" -relief "ridge"

# ---------------- Scrollbar  $w.v10.sb ---------------------
if {![winfo exists $w.v10.sb]} {scrollbar $w.v10.sb}
 $w.v10.sb configure -command "$w.v10.lb yview" -width "10"


# ---------------- Listbox  $w.v10.lb ---------------------
if {![winfo exists $w.v10.lb]} {listbox $w.v10.lb}
 $w.v10.lb configure -width "10" -yscrollcommand "$w.v10.sb set"


pack configure $w.v10.lb -in $w.v10 -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.v10.sb -in $w.v10 -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left

pack configure $w.v10 -in $w -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# ----------------- Bindings ---------------------------

bind $w.v10.lb <Configure> { 
	global history
        if {[%W index end] == 0} {
	    foreach line $history {
		%W insert end $line
	    }
        }
    }
bind $w.v10.lb <Button-1> {
	set line [%W get @%x,%y]
 	.cmd.e delete 0 end
        .cmd.e insert 0 $line
        destroy [winfo parent [winfo parent %W]]
    }
}
