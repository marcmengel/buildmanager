proc sessionwin_gui { w } {
global dir

# ---------------- Frame  $w ---------------------
if {![winfo exists $w]} {frame $w}
 $w configure -borderwidth "2" -height "50" -relief "ridge" -width "99"

# ---------------- Label  $w.l1 ---------------------
if {![winfo exists $w.l1]} {label $w.l1}
 $w.l1 configure -relief "sunken" -text "state" -width 18

# ---------------- Label  $w.l2 ---------------------
if {![winfo exists $w.l2]} {label $w.l2}
 $w.l2 configure -relief "sunken" -text "host" -width 18

# ---------------- Label  $w.l3 ---------------------
if {![winfo exists $w.l3]} {label $w.l3}
 $w.l3 configure -relief "sunken" -text "pstate" -width 18

# ---------------- Label  $w.l4 ---------------------
if {![winfo exists $w.l4]} {label $w.l4}
 $w.l4 configure -relief "sunken" -text "flavor" -width 18

# ---------------- Button $w.b --------------------
if {![winfo exists $w.b]} {button $w.b}
 $w.b configure -bitmap "@${dir}/lib/bitmaps/winsize.xbm" -command "\
     set h \[$w.v.t cget -height\] ;\
     if { \$h < 24 } {set h 24} else {set h 5} ;\
     $w.v.t configure -height \$h ;\
     $w.v.t see end \
 "

# ---------------- Checkbutton $w.b2 --------------------
if {![winfo exists $w.b2]} {checkbutton $w.b2}
$w.b2 configure -text "Log" -command "toggle_logging $w" \
		    -selectcolor green -variable "$w.b2.var"

# ---------------- Checkbutton $w.b3 --------------------
if {![winfo exists $w.b3]} {checkbutton $w.b3}
$w.b3 configure -text "Cmd" -command "toggle_cmd $w" \
		    -selectcolor green -variable "$w.b3.var"
$w.b3 select

# ---------------- Frame  $w.v ---------------------
if {![winfo exists $w.v]} {frame $w.v}
 $w.v configure -borderwidth "4" -relief "ridge"

# ---------------- Scrollbar  $w.v.sb ---------------------
if {![winfo exists $w.v.sb]} {scrollbar $w.v.sb}
 $w.v.sb configure -command "$w.v.t yview" -width "10"


# ---------------- Text  $w.v.t ---------------------
if {![winfo exists $w.v.t]} {text $w.v.t}
 $w.v.t configure -height 5 -width "80" -yscrollcommand "$w.v.sb set"
catch "$w.v.t tag add sel"
 $w.v.t tag configure sel -background "#c3c3c3" -borderwidth "1" -foreground "Black" -relief "raised"


pack configure $w.v.t -in $w.v -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.v.sb -in $w.v -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left

pack configure $w.v -in $w -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 -side right
pack configure $w.l1 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
pack configure $w.l2 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
pack configure $w.l3 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
pack configure $w.l4 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
pack configure $w.b2 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.b3 -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure $w.b -in $w -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side right
# ----------------- Bindings ---------------------------
}
