
proc update_bytes {} {
    global expect_out sw_dat

    if {[info exists expect_out(spawn_id)]} {
       rcvchars $sw_dat(s2w,$expect_out(spawn_id)) $expect_out(buffer)
    }
}

proc update_status { status } {
    global expect_out sw_dat pending1 pending2

    update_bytes
    set s $expect_out(spawn_id)
    setstatus $s $status
    if { $status == "Ready" && [info exists pending1($s)] } {
	catch $pending1($s)
	unset pending1($s)
    }
    if { $status == "Ready" && [info exists pending2($s)] } {
	catch $pending2($s)
	unset pending2($s)
    }
}

