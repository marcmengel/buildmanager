proc error_dialog {routine message} {
    global errorInfo

    set errortolist $errorInfo
puts $errortolist
    set res [tk_dialog .error "Error!" "Error in $routine: $message" {} 0 "Ok" "Info" "Exit" ]
    if {$res == 1} {
	puts $errortolist
    }
    if {$res == 2} {
	puts $errortolist
	exit
    }
}

