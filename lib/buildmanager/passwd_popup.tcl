proc passwd_popup { w } {

# ---------------- Toplevel  $w ---------------------
if {![winfo exists $w]} {toplevel $w}
 $w configure -height "100" -width "100" 
wm title $w {t2}
wm focusmodel $w active
wm transient $w .
wm geometry $w "+[winfo rootx .]+[expr 80+[winfo rooty .]]"

# ---------------- Label  $w.m1 ---------------------
if {![winfo exists $w.m1]} {message $w.m1}
 $w.m1 configure -textvariable login_reason -width 140

# ---------------- Entry  $w.e4 ---------------------
if {![winfo exists $w.e4]} {entry $w.e4}
 $w.e4 configure -width "10" -textvariable logname

# ---------------- Entry  $w.e3 ---------------------
if {![winfo exists $w.e3]} {entry $w.e3}
 $w.e3 configure -show "*" -width "10" -textvariable password

# ---------------- Label  $w.l5 ---------------------
if {![winfo exists $w.l5]} {label $w.l5}
 $w.l5 configure -relief "sunken" -text "password:"


# ---------------- Label  $w.l6 ---------------------
if {![winfo exists $w.l6]} {label $w.l6}
 $w.l6 configure -relief "sunken" -text "login:"


# ---------------- Button  $w.b10 ---------------------
if {![winfo exists $w.b10]} {button $w.b10}
 $w.b10 configure -command "destroy $w" -padx "13" -pady "4" -text "Dismiss"


grid configure $w.m1 -in $w -column 0 -row 0 -columnspan 2
grid configure $w.b10 -in $w -column 0 -row 3 -columnspan 2 -rowspan 1 -ipadx 0 -ipady 0 -padx 0 -pady 0 -sticky {}
grid configure $w.l6 -in $w -column 0 -row 1 -columnspan 1 -rowspan 1 -ipadx 0 -ipady 0 -padx 0 -pady 0 -sticky {}
grid configure $w.l5 -in $w -column 0 -row 2 -columnspan 1 -rowspan 1 -ipadx 0 -ipady 0 -padx 0 -pady 0 -sticky {}
grid configure $w.e4 -in $w -column 1 -row 1 -columnspan 1 -rowspan 1 -ipadx 0 -ipady 0 -padx 0 -pady 0 -sticky {}
grid configure $w.e3 -in $w -column 1 -row 2 -columnspan 1 -rowspan 1 -ipadx 0 -ipady 0 -padx 0 -pady 0 -sticky {}
# ----------------- Bindings ---------------------------
bind $w.e3 <Return> "destroy $w"
bind $w.e4 <Return> "focus $w.e3"
bind $w <Map> "focus $w.e4"
}
