proc customcmd_gui { w } {
global dir

# ---------------- Frame  $w ---------------------
if {![winfo exists $w]} {frame $w}
 $w configure -borderwidth "2" -relief "ridge"

# ---------------- Entry  $w.e ---------------------
if {![winfo exists $w.e]} {entry $w.e}

# ---------------- Button  $w.b5 ---------------------
if {![winfo exists $w.b5]} {button $w.b5}
 $w.b5 configure -bitmap "@${dir}/lib/bitmaps/popdown.xbm" -command " if {\[winfo exists $w.b5.hist\]} {destroy $w.b5.hist} else {historylist_popup $w.b5.hist} " 

# ---------------- Label  $w.l ---------------------
if {![winfo exists $w.l]} {label $w.l}
 $w.l configure -text "Command:"


# ---------------- Label  $w.l2 ---------------------
if {![winfo exists $w.l2]} {label $w.l2}
 $w.l2 configure -text "Product:"


# ---------------- Entry  $w.e2 ---------------------
if {![winfo exists $w.e2]} {entry $w.e2}
 $w.e2 configure -textvariable "product" -width "8"


# ---------------- Label  $w.l3 ---------------------
if {![winfo exists $w.l3]} {label $w.l3}
 $w.l3 configure -text "Version:"


# ---------------- Entry  $w.e3 ---------------------
if {![winfo exists $w.e3]} {entry $w.e3}
 $w.e3 configure -textvariable "version" -width "8"


pack configure $w.l2 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.e2 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.l3 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.e3 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.l -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.e -in $w -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.b5 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# ----------------- Bindings ---------------------------
do_cmd_bindings $w
bind $w.e <Key-F1> {puts [%W get];catch [%W get]}
bind $w.e <Key-Down> cmd_next
bind $w.e <Key-Up> cmd_previous
}
