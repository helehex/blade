# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Ansi Color Characters."""

comptime none = ""

comptime bold = "\033[1m"

comptime clear = "\033[0m"
comptime grey = "\033[30m"
comptime red = "\033[31m"
comptime green = "\033[32m"
comptime yellow = "\033[33m"
comptime blue = "\033[34m"
comptime pink = "\033[35m"
comptime cyan = "\033[36m"
comptime white = "\033[37m"

comptime bg_grey = "\033[40m"
comptime bg_red = "\033[41m"
comptime bg_green = "\033[42m"
comptime bg_yellow = "\033[43m"
comptime bg_blue = "\033[44m"
comptime bg_pink = "\033[45m"
comptime bg_cyan = "\033[46m"
comptime bg_white = "\033[47m"

comptime colors = [grey, red, yellow, green, cyan, blue, pink, white]

comptime bg_colors = [
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
