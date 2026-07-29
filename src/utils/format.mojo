# +----------------------------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +----------------------------------------------------------------------------------------------+ #
"""Format."""

# from std.collections.string import StringSlice
from std.collections.string.string import _unsafe_chr_ascii
from std.os import abort
from src.utils.length import len


@always_inline
def write_sign[WriterType: Writer](mut writer: WriterType, sign: Int):
    writer.write(_unsafe_chr_ascii(((-UInt8(sign == 0) & 5) | (-UInt8(sign < 0) & 2)) + 43))


@always_inline
def write_repeat[WriterType: Writer](mut writer: WriterType, reps: Int, string: String = " "):
    for _ in range(reps):
        writer.write(string)


@always_inline
def ctoi(char: StringSlice) -> Int:
    if len(char) != 1:
        abort("expected a character")
    var value = char.unsafe_ptr()[] - 48
    if value > 9:
        abort("expected a numeral")
    return Int(value)


@always_inline
def stoi(str: StringSlice) -> Int:
    if len(str) == 0:
        abort("expected a non-empty string")
    var result = 0
    var place = 1
    for byte in reversed(str.as_bytes()):
        var value = byte - 48
        if value > 9:
            abort("expected a numeral")
        result += Int(value) * place
        place *= 10
    return result
