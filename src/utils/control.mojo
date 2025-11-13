# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Assert"""


fn _assert[*Ts: Writable](expression: Bool, *msg: *Ts):
    if not expression:
        abort(String(msg))
