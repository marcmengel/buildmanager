proc customcmd_gui { w } {
	frame $w
	entry $w.e 
	bind $w.e <Key-Up>     "cmd_previous"
	bind $w.e <Key-Down>   "cmd_next"
	bind $w.e <Return>   "$w.e selection range 0 end; cmd_parallel \[$w.e get\]"
	bind $w.e <KP_Enter> "cmd_taketurns \[$w.e get\] \$sessionlist"
	label $w.l -text "Custom command:"

	label $w.l2 -text "Product:"
        entry $w.e2 -width 8 -textvariable product
	label $w.l3 -text "Version:"
        entry $w.e3 -width 8 -textvariable version
	pack $w.l2 $w.e2 $w.l3 $w.e3 $w.l -side left
	pack $w.e  -fill x -expand 0 -side left
}
