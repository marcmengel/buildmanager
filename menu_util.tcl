proc fill_in_cmd_menu { w } {
    global cmd_menu
    set count 0
    foreach label [lsort [array names cmd_menu]] {
	# puts "label $label command $cmd_menu($label)"
	incr count
	catch "$w.m4.m add command"
	$w.m4.m entryconfigure $count -command $cmd_menu($label) -label $label
    }
}
