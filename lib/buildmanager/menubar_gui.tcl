proc menubar_gui { w } {

# ---------------- Frame  $w ---------------------
if {![winfo exists $w]} {frame $w}
 $w configure -borderwidth "2" -height "50" -relief "ridge" -width "99"

# ---------------- Menubutton  $w.m4 ---------------------
if {![winfo exists $w.m4]} {menubutton $w.m4}
 $w.m4 configure -menu "$w.m4.m" -padx "6" -pady "5" -text "Commands"

# ---------------- Menu  $w.m4.m ---------------------
if {![winfo exists $w.m4.m]} {menu $w.m4.m}
catch "$w.m4.m add tearoff "

# ---------------- Menubutton  $w.m5 ---------------------
if {![winfo exists $w.m5]} {menubutton $w.m5}
 $w.m5 configure -menu "$w.m5.m" -padx "6" -pady "5" -text "Edit"

# ---------------- Menu  $w.m5.m ---------------------
if {![winfo exists $w.m5.m]} {menu $w.m5.m}
catch "$w.m5.m add tearoff "



# ---------------- Button  $w.b6 ---------------------
if {![winfo exists $w.b6]} {button $w.b6}
 $w.b6 configure -padx "13" -pady "4" -text "Help..." -command {
	 source "${dir}/lib/buildmanager/mgui_help.tcl"
 }



pack $w.b6 -side right -expand 0
pack $w.m4 -side left -expand 0
pack $w.m5 -side left -expand 0
# ----------------- Bindings ---------------------------
}
