proc hostlist_editor { w } {

# ---------------- Toplevel  $w ---------------------
if {![winfo exists $w]} {toplevel $w}
 $w configure -height "100" -width "100"
wm geometry $w 568x326+26+301
wm minsize $w 1 1
wm maxsize $w 1009 738
wm title $w {t11}
wm focusmodel $w passive

# ---------------- Menubutton  $w.m13 ---------------------
if {![winfo exists $w.m13]} {menubutton $w.m13}
 $w.m13 configure -menu "$w.m13.m" -padx "4" -pady "3" -text "List" -underline "0"

# ---------------- Menu  $w.m13.m ---------------------
if {![winfo exists $w.m13.m]} {menu $w.m13.m}
catch "$w.m13.m add tearoff "
catch "$w.m13.m add command "
 $w.m13.m entryconfigure 1 -command "unset configured($w.v6.t); destroy $w" -label "Dismiss" -underline "0"
catch "$w.m13.m add command "
 $w.m13.m entryconfigure 2 -command "change_hosts $w.v6.t" -label "Update" -underline "0"



# ---------------- Frame  $w.v6 ---------------------
if {![winfo exists $w.v6]} {frame $w.v6}
 $w.v6 configure -borderwidth "4" -relief "ridge"

# ---------------- Scrollbar  $w.v6.sb ---------------------
if {![winfo exists $w.v6.sb]} {scrollbar $w.v6.sb}
 $w.v6.sb configure -command "$w.v6.t yview" -width "10"


# ---------------- Text  $w.v6.t ---------------------
if {![winfo exists $w.v6.t]} {text $w.v6.t}
 $w.v6.t configure -height "1" -width "1" -yscrollcommand "$w.v6.sb set"
catch "$w.v6.t tag add sel"
 $w.v6.t tag configure sel -background "#c3c3c3" -borderwidth "1" -foreground "Black" -relief "raised"


pack configure $w.v6.t -in $w.v6 -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.v6.sb -in $w.v6 -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left

pack configure $w.v6 -in $w -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom
pack configure $w.m13 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# ----------------- Bindings ---------------------------
bind $w.v6.t <Configure> {
   if {! [info exists configured(%W)]} {
       set configured(%W) 1
       fill_hosts %W
    }
}

}
