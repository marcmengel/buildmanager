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
catch "$w.m5.m add command "
 $w.m5.m entryconfigure 1 -command "edit_hosts" -label "Hostlist"
catch "$w.m5.m add checkbutton "
 $w.m5.m entryconfigure 2 -onvalue 1 -offvalue 0 -variable vt100seenew -label "See bottom on new text"


# ---------------- Button  $w.b6 ---------------------
if {![winfo exists $w.b6]} {button $w.b6}
 $w.b6 configure -command "
	 source \"\${dir}/lib/buildmanager/mgui_help.tcl\"
 " -padx "13" -pady "4" -text "Help..."

# ---------------- Label -----------------------------
label $w.l4 -text "Connect:"

# ---------------- Menubutton  $w.m6 ---------------------
if {![winfo exists $w.m6]} {menubutton $w.m6}
 $w.m6 configure -menu "$w.m6.m" -padx "6" -pady "4" -textvariable "connect_command"

# ---------------- Menu  $w.m6.m ---------------------
if {![winfo exists $w.m6.m]} {menu $w.m6.m}
catch "$w.m6.m add tearoff "
catch "$w.m6.m add command "
 $w.m6.m entryconfigure 1 -command "set connect_command /usr/krb5/bin/rsh" -label "/usr/krb5/bin/rsh"
catch "$w.m6.m add command "
 $w.m6.m entryconfigure 2 -command "set connect_command /usr/local/bin/ssh" -label "/usr/krb5/bin/ssh"
catch "$w.m6.m add command "
 $w.m6.m entryconfigure 3 -command "set connect_command /usr/bin/rsh" -label "/usr/bin/rsh"
catch "$w.m6.m add command "
 $w.m6.m entryconfigure 4 -command "set connect_command /usr/bin/telnet" -label "/usr/bin/telnet"
catch "$w.m6.m add command "
 $w.m6.m entryconfigure 5 -command "set connect_command /usr/afsws/bin/rsh" -label "/usr/afsws/bin/rsh"




pack configure $w.b6 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side right
pack configure $w.m4 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.m5 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.l4 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.m6 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# ----------------- Bindings ---------------------------
}
