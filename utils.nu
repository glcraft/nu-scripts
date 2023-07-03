#!/usr/bin/env nu

# MIT LICENCE
#
# Copyright 2023 Gabin Lefranc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
# SOFTWARE.

export use markdown.nu

export def repeat [
    text: string 
    count: int
] {
    (0..<$count | each {|| $text} | str join)
}

def power-rename [
  from: string,
  to: any,
  --yes(-y)
] {
    let input = $in
    let result = ($input
        | get name
        | each { |it| 
            let parsed = ($it | parse $from)
            if ($parsed | is-empty) {
                null
            } else {
                {
                    in:$it, 
                    out:(do $to ($parsed | first))
                }
            }
        }
        | where {|it| $it != null })
        

    if not $yes {
        if ($result | is-empty) {
            print "Nothing to do"
            return
        } else {
            print "List of change :"
            print $result
            if (input "Do you want to apply this change ? (y/n) ") != "y" {
                return
            }
        }
    }
    $result | each {
        mv $in.in $in.out
    } | ignore
}