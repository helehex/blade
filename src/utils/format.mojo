# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Format"""

from collections.string import StringSlice
from collections.string.string import _chr_ascii


@always_inline
fn write_sign[WriterType: Writer](mut writer: WriterType, sign: Int):
    writer.write(
        _chr_ascii(
            ((-(sign == 0).__int__() & 5) | (-(sign < 0).__int__() & 2)) + 43
        )
    )


@always_inline
fn write_repeat[
    WriterType: Writer
](mut writer: WriterType, reps: Int, string: String = " "):
    for _ in range(reps):
        writer.write(string)


@always_inline
fn ctoi(char: StringSlice) -> Int:
    if len(char) != 1:
        abort("expected a character")
    var value = char.unsafe_ptr()[] - 48
    if value > 9:
        abort("expected a numeral")
    return Int(value)


@always_inline
fn stoi(str: StringSlice) -> Int:
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
