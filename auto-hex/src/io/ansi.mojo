# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #


struct Color:
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

    alias colors = List[String](
        Self.grey, Self.red, Self.yellow, Self.green, Self.cyan, Self.blue, Self.pink, Self.white
    )

    alias bg_colors = List[String](
        Self.bg_grey,
        Self.bg_red,
        Self.bg_yellow,
        Self.bg_green,
        Self.bg_cyan,
        Self.bg_blue,
        Self.bg_pink,
        Self.bg_white,
    )
