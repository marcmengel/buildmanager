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
catch "$w.m4.m add command "
 $w.m4.m entryconfigure 1 -command "menu_cd" -label "cd to build area"
catch "$w.m4.m add command "
 $w.m4.m entryconfigure 2 -command "menu_checkout" -label "cvs checkout"
catch "$w.m4.m add command "
 $w.m4.m entryconfigure 3 -command "menu_make declare 1" -label "make declare"
catch "$w.m4.m add command "
 $w.m4.m entryconfigure 4 -command "menu_setup_product" -label "setup"
catch "$w.m4.m add command "
 $w.m4.m entryconfigure 5 -command "menu_make all" -label "make all"
catch "$w.m4.m add command "
 $w.m4.m entryconfigure 6 -command "menu_make test" -label "make test"
catch "$w.m4.m add command "
 $w.m4.m entryconfigure 7 -command "menu_make \$releasetarget" -label "release"
catch "$w.m4.m add command "
 $w.m4.m entryconfigure 8 -command "menu_exit" -label "Exit"
catch "$w.m4.m add command "
 $w.m4.m entryconfigure 9 -command "menu_make clean" -label "make clean"

# ---------------- Menubutton  $w.m5 ---------------------
if {![winfo exists $w.m5]} {menubutton $w.m5}
 $w.m5 configure -menu "$w.m5.m" -padx "6" -pady "5" -text "Edit"

# ---------------- Menu  $w.m5.m ---------------------
if {![winfo exists $w.m5.m]} {menu $w.m5.m}
catch "$w.m5.m add tearoff "



# ---------------- Button  $w.b6 ---------------------
if {![winfo exists $w.b6]} {button $w.b6}
 $w.b6 configure -padx "13" -pady "4" -text "Help..."


pack $w.b6 -side right
pack $w.m4 -side left
pack $w.m5 -side left
# ----------------- Bindings ---------------------------
}
