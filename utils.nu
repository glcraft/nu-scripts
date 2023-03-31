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

export def repeat [
    text: string 
    count: int
] {
    (0..<$count | each {|| $text} | str join)
}

export-env {
    let-env MARKDOWN_THEME = {
        code: "93"
        link: "36"
        title: "1;47;30"
        prompt: "32"
        bold_italic: "1;3"
        bold: "1"
        italic: "3"
    }
}

def md_theme [] {
    let theme = ($env | get -i MARKDOWN_THEME)
    if $theme == null {
        {
            code: "93"
            link: "36"
            title: "1;47;30"
            prompt: "32"
            bold_italic: "1;3"
            bold: "1"
            italic: "3"
        }
    } else {
        $theme
    }
}

def md_line [] {
    let size = ((term size | get columns)) - 2
    let line = (char -u "2500")
    let line_stop_right = (char -u "2574")
    let line_stop_left = (char -u "2576")
    print $"\n($line_stop_left)(1..$size | each {|| $line } | str join)($line_stop_right)\n"

}

def md_title [
    title: string 
    level: int = 1
] {
    let size = ((term size | get columns) / (1 bit-shl ($level - 1))) - 4
    if $size < 0 {
        print $"\n(ansi -e $"((md_theme).title)m") ($title) (ansi reset)\n"
        return
    }
    let title_length = ($title | str length)
    let left = (($size / 2) - $title_length / 2)
    let right = ($size - $left - $title_length)
    let line = (char -u "2500")
    let line_stop_left = (char -u "2574")
    let line_stop_right = (char -u "2576")
    print $"\n(1..$left | each {|| $line } | str join)($line_stop_left)(ansi -e $"((md_theme).title)m") ($title) (ansi reset)($line_stop_right)(1..$right | each {|| $line } | str join)\n"
}

export def "parse advanced" [
    pattern: string
    reconstruct: closure
    --regex(-r)
] {
    let input = $in
    let parsed = ($input | if $regex {parse -r $pattern} else {parse $pattern})
    mut list_result = []
    mut previous = 0
    if ($parsed | length) > 0 {
        for $i in 0..<($parsed | length) {
            let current = ($parsed | get $i)
            let reconstructed = (do $reconstruct $current)
            let begin = ($input | str index-of -r $"($previous)," $reconstructed)
            let end = ($begin + ($reconstructed | str length))
            $list_result = ($list_result | append ($current | merge {
                begin: $begin
                end: $end
                reconstructed: $reconstructed
            }))
            $previous = $end
        }
    }
    $list_result
}
def md_add_modifier [
    previous_modifier?: list
] {
    let text = $in
    mut text = $text
    let append_modifier = { |mod| ansi -e $'($previous_modifier | append [$mod] | str join ";")m'}
    let apply_prev_mod = (if $previous_modifier == null {ansi reset} else {[(ansi reset) (ansi -e $'($previous_modifier | str join ";")m')] | str join})
    if $text =~ '\[[^\]]+\]\([^)]+\)' {
        let captured_data = ($text | parse -r '\[(?<text>[^\]]+)\]\((?<url>[^)]+)\)')
        if ($captured_data | length) > 0 {
            for $i in 0..<($captured_data | length) {
                let current = ($captured_data | get $i)
                let captured = $"[($current.text)]\(($current.url)\)"
                $text = ($text | str replace -s $captured $"(do $append_modifier (md_theme).link)($current.url | ansi link --text $current.text)($apply_prev_mod)")
            }
        }
    }
    if ($text =~ '`[^`]+`') {
        $text = ($text | str replace "`([^`]+)`" $"(do $append_modifier (md_theme).code)$1($apply_prev_mod)")
    }
    if ($text =~ '\*\*\*(?:(?!\*\*\*).)+\*\*\*') {
        let parsed = ($text | parse -r '\*\*\*(?<text>(?:(?!\*\*\*).)+)\*\*\*')
        if ($parsed | length) > 0 {
            for $i in 0..<($parsed | length) {
                let current = ($parsed | get $i)
                let captured = $"***($current.text)***"
                $text = ($text | str replace -s $captured $"(do $append_modifier (md_theme).bold_italic)($current.text | md_add_modifier ($previous_modifier | append [(md_theme).bold_italic]))($apply_prev_mod)")
            }
        }
    }
    if ($text =~ '\*\*(?:(?!\*\*).)+\*\*') {
        let parsed = ($text | parse -r '\*\*(?<text>(?:(?!\*\*).)+)\*\*')
        if ($parsed | length) > 0 {
            for $i in 0..<($parsed | length) {
                let current = ($parsed | get $i)
                let captured = $"**($current.text)**"
                $text = ($text | str replace -s $captured $"(do $append_modifier (md_theme).bold)($current.text | md_add_modifier ($previous_modifier | append [(md_theme).bold]))($apply_prev_mod)")
            }
        }
    }
    if ($text =~ '\*[^*]+\*') {
        let parsed = ($text | parse -r '\*(?<text>[^*]+)\*')
        if ($parsed | length) > 0 {
            for $i in 0..<($parsed | length) {
                let current = ($parsed | get $i)
                let captured = $"*($current.text)*"
                $text = ($text | str replace -s $captured $"(do $append_modifier (md_theme).italic)($current.text | md_add_modifier ($previous_modifier | append [(md_theme).italic]))($apply_prev_mod)")
            }
        }
    }
    $text
}

export def "display markdown" [
    --no-bat(-b)
    --force-nu
] {
    let $input = $in
    mut markdown = $input
    mut code_lang = ""
    mut code = []
    mut is_code = false
    for $line in ($markdown | lines) {
        
        if ($line =~ "^```") {
            if $is_code == true {
                let str_code = ($code | str join "\n")
                let bat = (which bat)
                if ($bat | length) > 0 and (not $no_bat) {
                    mut bat_args = [--color always --paging never --file-name $"code ($code_lang)" -]
                    
                    if ($code_lang | is-empty) == false  and $code_lang != "nu" {
                        $bat_args = ($bat_args | append ["--language" $code_lang])
                    }
                    if $code_lang == "nu" {
                        $str_code | nu-highlight | bat $bat_args
                    } else {
                        $str_code | bat $bat_args
                    }
                    
                } else {
                    if $code_lang == "nu" or $force_nu {
                        $str_code | nu-highlight | print
                    } else {
                        print $str_code
                    }
                }
                $code = []
                $code_lang = ""
                $is_code = false
            } else {
                let langs = ($line | parse -r '^```(?<lang>\w+)')
                $code_lang = (if ($langs | length) > 0 {($langs | get 0.lang)} else {null})
                $code = []
                $is_code = true
            }
            continue
        } 
        if $is_code == true {
            $code = ($code | append [$line])
            continue
        }

        if ($line =~ '^\s*#+\s+') {
            let parsed = ($line | parse -r '^\s*(?<ht>#+)\s+(?<name>.*)$' | get 0)
            md_title $parsed.name ($parsed.ht | str length)
            continue
        } 
        if ($line =~ '^-{3,}$') {
            md_line
            continue
        }

        mut newline = $line
        
        if ($newline =~ '^\s*-\s+') {
            let parsed = ($line | parse -r '^(\s*)(-\s+)' | get 0 )
            let index = (($parsed.capture0 | str length) + ($parsed.capture1 | str length))
            let spacing = ($parsed.capture0 | str length)
            $newline = $"(repeat ' ' $spacing)(char prompt) ($newline | str substring $index..)"
        }

        $newline = ($newline | md_add_modifier)
        print $newline
        print -n (ansi reset)
    }
}