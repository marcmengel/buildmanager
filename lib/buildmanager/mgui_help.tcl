
. configure -cursor watch
# ---------------- Toplevel .help ---------------------
if {![winfo exists .help]} {toplevel .help}
wm geometry .help 600x400+200+0
wm minsize .help 1 1
wm maxsize .help 1265 994
wm title .help Help
wm focusmodel .help passive

# ---------------- Menubutton .help.m3 ---------------------
if {![winfo exists .help.m3]} {menubutton .help.m3}
 .help.m3 configure -menu .help.m3.m -padx 6 -pady 5 -text File -underline 0

# ---------------- Menu .help.m3.m ---------------------
if {![winfo exists .help.m3.m]} {menu .help.m3.m}
catch ".help.m3.m add tearoff"
catch ".help.m3.m add command"
 .help.m3.m entryconfigure 1 -command {destroy .help} -label {Close Help}



# ---------------- Frame .help.h3 ---------------------
if {![winfo exists .help.h3]} {frame .help.h3}
 .help.h3 configure -borderwidth 4 -relief ridge

# ---------------- Scrollbar .help.h3.bb ---------------------
if {![winfo exists .help.h3.bb]} {scrollbar .help.h3.bb}
 .help.h3.bb configure -command {.help.h3.t xview} -orient horizontal -width 10


# ---------------- Scrollbar .help.h3.sb ---------------------
if {![winfo exists .help.h3.sb]} {scrollbar .help.h3.sb}
 .help.h3.sb configure -command {.help.h3.t yview} -width 10


# ---------------- Text .help.h3.t ---------------------
if {![winfo exists .help.h3.t]} {text .help.h3.t}
 .help.h3.t configure -height 1 -width 1 -wrap none -xscrollcommand {.help.h3.bb set} -yscrollcommand {.help.h3.sb set}
catch ".help.h3.t tag add sel"
 .help.h3.t tag configure sel -background #c3c3c3 -borderwidth 1 -foreground Black -relief raised


pack configure .help.h3.bb -in .help.h3 -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom
pack configure .help.h3.t -in .help.h3 -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
pack configure .help.h3.sb -in .help.h3 -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left

pack configure .help.m3 -in .help -anchor w -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
pack configure .help.h3 -in .help -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom
# ----------------- Bindings ---------------------------
bind .help.h3.t <Configure> {    
    .help.h3.t configure -cursor watch
    global env
    global donethat
    if { ![info exists donethat] || $donethat == 0 } {
        set donethat 1
	html_insert_file .help.h3.t "$env(BUILDMANAGER_DIR)/doc/buildmanager.html" 
    }
}

bind .help.h3 <Destroy> {
    global donethat
    set donethat 0
}
. configure -cursor {}
