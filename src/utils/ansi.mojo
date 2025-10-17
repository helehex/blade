# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Ansi Color Characters."""

alias none = ""

alias bold = "\033[1m"

alias clear = "\033[0m"
alias grey = "\033[30m"
alias red = "\033[31m"
alias green = "\033[32m"
alias yellow = "\033[33m"
alias blue = "\033[34m"
alias pink = "\033[35m"
alias cyan = "\033[36m"
alias white = "\033[37m"

alias bg_grey = "\033[40m"
alias bg_red = "\033[41m"
alias bg_green = "\033[42m"
alias bg_yellow = "\033[43m"
alias bg_blue = "\033[44m"
alias bg_pink = "\033[45m"
alias bg_cyan = "\033[46m"
alias bg_white = "\033[47m"

alias colors = [grey, red, yellow, green, cyan, blue, pink, white]

alias bg_colors = [
    bg_grey,
    bg_red,
    bg_yellow,
    bg_green,
    bg_cyan,
    bg_blue,
    bg_pink,
    bg_white,
]

fn get_color(idx: Int) -> String:
    return materialize[colors]()[(idx % 6) + 1]

fn get_bg_color(idx: Int) -> String:
    return materialize[bg_colors]()[(idx % 6) + 1]