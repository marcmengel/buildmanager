
#
# patterns to look at the file
#
set html_tag_patttern 	 {^[ 	]*<(/?)([a-zA-Z]+)([^>]*)>} 
set html_word_pattern 	 {^[ 	]*([^ 	<]+)} 
set html_pre_pattern 	 {^[ 	]*<pre>}
set html_end_pre_pattern {^[ 	]</pre>}

# backwards compat with old tcl
if [ catch "file join a b" ] {
    proc file_join { a b } { return "$a/$b" }
} else {
    proc file_join { a b } { return [file join $a $b] }
}

if [ catch "file dirname a/b" ] {
    proc file_dirname { a } { regsub {.*/} $a {} a; return $a }
} else {
    proc file_dirname { a } { return [file dirname $a] }
}

#
# main routine to insert an html file in a text widget
#

proc html_insert_file { w file {anchor ""} {debug ""} } {
    global html_tag_patttern html_word_pattern html_pre_pattern 
    global html_end_pre_pattern html_debug_flag
    global html_dirnames

    $w configure -cursor watch
    update
    set formatting 1
    if { "$debug" != "" } {
        set html_debug_flag $debug
    }

    html_clean_images $w
    $w delete 0.0 end
    bind $w <Destroy> {html_clean_images %W}
    update

    if {![info exists html_dirnames($w)]} {
	set html_dirnames($w) "" 
    } 

    set html_dirnames($w) [file_join $html_dirnames($w) [file_dirname $file]]
    set file [file tail $file]

    html_paint_tags $w

    set fd [open [file_join $html_dirnames($w) $file] "r" ]
    set count 0
    while { -1 < [ gets $fd line ] } {
	incr count
	if {($count % 32) == 0} {
	    update
	}
	html_debug "new line >|$line|<"
  	 while { "$line" != "" } {
	     html_debug "formatting"

	     if { !$formatting } {
		regexp {^[ 	]*} $line spaces
		html_debug "inserting spaces >|$spaces|<"
		$w insert insert $spaces
	     }
	     if { [regexp -nocase $html_pre_pattern $line] } {
		html_debug "matched a <pre> at [$w index insert]"
		regsub -nocase $html_pre_pattern $line {} line
		set formatting 0
		html_do_pre $w "" ""
	     } elseif { [regexp -nocase $html_tag_patttern $line match slash tag arg] } {
		set tag [string tolower $tag]
		html_debug "matched a <$slash$tag...> at [$w index insert]"
		regsub -nocase $html_tag_patttern $line {} line
		if { "html_do_$tag" == [info command "html_do_$tag"] } {
		    html_do_$tag $w $slash $arg
		}
	     } elseif { [regexp -nocase $html_end_pre_pattern $line match upto] } {
		 html_debug "matched a </pre> at [$w index insert]"
		 regsub -nocase $html_end_pre_pattern $line {} line
                 regsub -nocase {\&lt;} $upto {<} upto
                 regsub -nocase {\&gt;} $upto {>} upto
                 regsub -nocase {\&amp;} $upto {\&} upto
                 regsub -nocase {\&nbsp;} $upto { } upto
		 $w insert insert "$upto" {}
		 html_do_pre $w "/" ""
		 set formatting 1
	     } elseif { [regexp -nocase $html_word_pattern $line match word ]} {
		html_debug "matched a word >|$word|< at [$w index insert]"
		regsub -nocase $html_word_pattern $line {} line
                regsub -nocase {\&lt;} $word {<} word
                regsub -nocase {\&gt;} $word {>} word
                regsub -nocase {\&amp;} $word {\&} word
                regsub -nocase {\&nbsp;} $word { } word
	        $w insert insert $word {}
		if { $formatting } {
		    $w insert insert " " {}
		}
	     } elseif { [regexp {^[ 	]*} $line] } {
		set line {}
	     } else {
		puts "line $line -- nothing matched!!"
		break
	     }
	     html_debug "line is now >|$line|< at [$w index insert]"
	 }
	 if { !$formatting } {
	     html_debug "inserting newline"
	     $w insert insert "\n"
	 }
     }
     close $fd
     catch "$w see html_a_$anchor"
     update
     $w configure -cursor {}
}

#
# define tags to paint the anchors, etc prettily.
# note that these don't nest worth a darn...
#
proc html_paint_tags { w } {
     array set fsz {0 12 1 14 2 18 3 20 4 24}
     $w configure -wrap word
     $w configure -font  -*-helvetica-medium-r-normal--$fsz(0)-*
     $w tag configure html_strong -font -*-helvetica-bold-r-normal--$fsz(0)-*
     $w tag configure html_em -font -*-helvetica-medium-o-normal--$fsz(0)-*
     $w tag configure html_tt -font  -*-courier-medium-r-normal--$fsz(0)-*
     $w tag configure html_h_1 -font -*-helvetica-bold-r-normal--$fsz(4)-*
     $w tag configure html_h_2 -font -*-helvetica-bold-r-normal--$fsz(3)-*
     $w tag configure html_h_3 -font -*-helvetica-bold-r-normal--$fsz(2)-*
     $w tag configure html_h_4 -font -*-helvetica-bold-r-normal--$fsz(1)-*
     $w tag configure html_h_5 -font -*-helvetica-bold-r-normal--$fsz(0)-* \
				-underline 1
     $w tag configure html_pre -font -*-courier-medium-r-normal--$fsz(0)-*
     $w tag configure html_center -justify center
     $w tag configure html_li_0 -lmargin1 00 -lmargin2 10
     $w tag configure html_li_1 -lmargin1 10 -lmargin2 20
     $w tag configure html_li_2 -lmargin1 20 -lmargin2 30
     $w tag configure html_li_3 -lmargin1 30 -lmargin2 40
     $w tag configure html_blockquote -lmargin1 10 -lmargin2 10 -rmargin 10
     $w tag configure html_address -font  -*-helvetica-medium-o-normal--$fsz(0)-*
     $w tag configure html_u -underline true
     $w tag lower html_pre
     $w tag lower html_address
}

#
# tags implmented as aliases for others
#
proc html_do_ol { w slash arg }  	{html_do_nl $w $slash $arg}
proc html_do_i { w slash arg }  	{html_do_em $w $slash $arg}
proc html_do_b { w slash arg }  	{html_do_strong $w $slash $arg}
proc html_do_kbd { w slash arg }  	{html_do_tt $w $slash $arg}

#
# html_do_<tag> for various tags, does <tag> and </tag>
#    based on "slash" argument
#

proc html_do_title { w slash arg } {
    global html_titlestart
    if { "$slash" == "" } {
	set html_titlestart [$w index insert]
    } else {
	if {[info exists html_titlestart]} {
	    set title [$w get $html_titlestart [$w index insert]]
	    $w delete $html_titlestart [$w index insert]
	    while { "$w" != ""  && [catch [list wm title $w $title]] } {
		set w [winfo parent $w]
	    }
	}
    }
}

set html_list_depth 0
set html_saw_item(0) 0
set html_list_counter(0) -1

proc html_do_ul { w slash arg } {
    global html_list_depth html_saw_item html_list_counter

    if { "$slash" == "" } {
        incr html_list_depth

	set html_saw_item($html_list_depth) 0
	set html_list_counter($html_list_depth) -1
    } else {
	# end the last html_li tagged region
        if { $html_saw_item($html_list_depth) } {
  	    html_tag html_li_$html_list_depth $w "/"
        }
	set html_list_depth [expr $html_list_depth - 1]
        $w insert insert "\n" {}
    }
}

proc html_do_nl { w slash arg } {
    global html_list_depth html_saw_item html_list_counter

    if { "$slash" == "" } {
        incr html_list_depth
	set html_saw_item($html_list_depth) 0
	set html_list_counter($html_list_depth) 0
    } else {
	# end the html_li tagged region
        if { $html_saw_item($html_list_depth) } {
  	    html_tag html_li_$html_list_depth $w "/"
        }
	set html_list_depth [expr $html_list_depth - 1]
        $w insert insert "\n"
    }
}

proc html_do_li { w slash arg } {
    global html_list_depth html_saw_item html_list_counter

    if { "$slash" == "" } {
	# end the previous html_li tagged region, if any
	if { $html_saw_item($html_list_depth) } {
	    html_tag html_li_$html_list_depth $w "/"
	}
	$w insert insert "\n"
	html_tag html_li_$html_list_depth  $w ""
	if { $html_list_counter($html_list_depth) == -1 } {
	   $w insert insert "*  "
	} else {
	    incr html_list_counter($html_list_depth)
	    $w insert insert "$html_list_counter($html_list_depth). "
	}
	set html_saw_item($html_list_depth) 1
    }
}

proc html_do_br { w slash arg } {
    $w insert insert "\n" {html_br boundaries}
}

set html_paragraph_flag 0

proc html_do_p { w slash arg } {
    global html_paragraph_flag 

    # end un-ended paragraphs before starting new ones...
    if {"" == "$slash" && $html_paragraph_flag } {
	html_do_p $w "/" $arg
    }

    $w insert insert "\n" 
    # html_tag "html_p" $w $slash
    set html_paragraph_flag [expr {"$slash" != "/"} ]
}

proc html_do_hr { w slash arg } {
    $w insert insert \
	"\n___________________________________________________\n" \
	{html_hr boundaries}
}

proc html_do_pre { w slash arg } {
    $w insert insert "\n"
    html_tag "html_pre" $w $slash
}

proc html_do_blockquote { w slash arg } {
    html_tag "html_blockquote" $w $slash
}

proc html_do_address { w slash arg } {
    html_tag "html_address" $w $slash
}

proc html_do_tt { w slash arg } {
    html_tag "html_tt" $w $slash
}

proc html_do_u { w slash arg } {
    html_tag "html_u" $w $slash
}

proc html_do_strong { w slash arg } {
    html_tag "html_strong" $w $slash
}

proc html_do_em { w slash arg } {
    html_tag "html_em" $w $slash
}

proc html_do_h { w slash arg } {
    global html_paragraph_flag

    # throw away rest of arg after blank
    regsub { .*} $arg {} arg	

    # end un-ended paragraphs before starting headers...
    if {"" == "$slash" && $html_paragraph_flag } {
	html_do_p $w "/" $arg
    }
    if { "$slash" == "" } {
        html_do_p $w $slash $arg
    }
    $w insert insert "\n"
    html_tag "html_h_$arg" $w $slash
    if { "$slash" == "/" } {
        html_do_p $w $slash $arg
    }
}

set html_n_anchors 0
proc html_do_a { w slash arg } {
    global html_n_anchors

    if { "$slash" == "" } {
	incr html_n_anchors
	$w tag configure html_a_$html_n_anchors -foreground blue -underline 1

	if { [regexp -nocase {name="([^"]*)"} $arg match anchor] } {
	    html_debug "doing $w mark set html_a_$anchor [$w index insert]"
	    $w mark set html_a_$anchor [$w index insert]
	}

	if { [regexp -nocase {href="([^"\#]*)\#?([^"]*)"} $arg match filename anchor] } {
	    if { "$filename" != "" } {
		$w tag bind html_a_$html_n_anchors <ButtonPress> \
		    [list html_insert_file $w $filename $anchor]
		html_debug "binding html_a_$html_n_anchors to $filename\#$anchor"
	    } else {
		$w tag bind html_a_$html_n_anchors <ButtonPress> \
		    [ list $w see html_a_$anchor ]
		html_debug "binding html_a_$html_n_anchors to $w see html_a_$anchor"
	    }
	}

        html_tag html_a_$html_n_anchors $w  $slash
    } else {
        html_tag html_a_* $w  $slash
    }
}

#
# routines to do with begin/end tags
#
set html_stack {}
proc html_tag { tag w slash } {
    global html_stack

    if { "$slash" == ""  } {
        html_debug "starting $tag at [$w index insert]"
	lappend html_stack [list $tag [$w index insert]]
	html_debug "stack is now >|$html_stack|<"
    } else {
        html_debug "ending $tag at [$w index insert]"
	if { [llength $html_stack ]  == 0 } {
		tk_dialog $w.pop "html syntax error" \
		    "end tag </$tag> at [$w index insert] has no start" \
		    {} 0 "Ignore" 
	} else {
	    set taginfo [lindex $html_stack end]
	    html_debug "taginfo is >|$taginfo|<"
	    set stacktag [lindex $taginfo 0]
	    set index [lindex $taginfo 1]
	    if { ! [string match $tag $stacktag ] } {
		set eatit [ tk_dialog $w.pop "html syntax error" \
		    "tag <$stacktag> at $index ended by tag </$tag> at [$w index insert], treat as a match?" \
		    {} 0 "Ignore" "Match" ]
	    } else {
		set eatit 1
	    }
	    if $eatit {
		set html_stack [lreplace $html_stack end end ]
	    }
	    html_debug "stack is now >|$html_stack|<"
	    html_debug "doing: $w tag add $stacktag $index [$w index insert]"
	    $w tag add $stacktag  ${index} [$w index insert]
	    $w tag add boundaries [$w index insert-1c]
	    $w tag add boundaries ${index} 
	}
    }
}

set html_n_images 0
proc html_do_img { w slash arg } {
    global html_n_images
    global html_dirnames

    if { [regexp -nocase {.*src="([^"]*)"} $arg match file] } {
	incr html_n_images
	if ![catch {
	       set imagename [image create photo -file \
			[file_join $html_dirnames($w) $file]]} res] {
	    canvas $w.image$html_n_images \
		    -width [image width $imagename] \
		    -height [image height $imagename]
	    $w.image$html_n_images create image 0 0 -image $imagename -anchor nw
	    $w window create insert -window $w.image$html_n_images
	}
	$w tag add "html_img_$file" [$w index insert-1c]
	$w tag add boundaries [$w index insert-1c]
    }
}

proc html_clean_images { w } {
    foreach kid [winfo children $w] {
	if ![catch {$kid itemcget 1 -image} result ] {
	    if { "$result" != "" } {
		image delete $result 
	    }
	}
    }
}

set html_debug_flag 0

proc html_debug { s } {
    global html_debug_flag
    if {$html_debug_flag} {
	puts stderr $s
    }
}

