# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Assert"""


fn _assert[*Ts: Writable](expression: Bool, *msg: *Ts):
    if not expression:
        abort(String(msg))
