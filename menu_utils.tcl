#
# routines invoked by the menubar...
#
proc menu_cd {} {
    global sessionlist
    cmd_parallel "cd [productroot]" 
}

proc menu_checkout {} {
    global product version

    cmd_parallel \
    "cd [productroot 1]; cvs checkout -r $version -d [productroot 2] $product"
}

proc menu_make { target {taketurns 0} } {
    if { $taketurns } {
        cmd_taketurns "make $target"
    } else {
        cmd_parallel "make $target"
    }
}

proc menu_setup_product {} {
    global product version

    cmd_parallel "setup -b $product $version"
}

proc menu_exit {} {
    cmd_parallel "exit"
    after 5000 exit
}
