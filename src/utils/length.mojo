from std.builtin.len import len as _len

def len(str: String) -> Int:
    return str.byte_length()

def len(str: StringSlice) -> Int:
    return str.byte_length()

def len[T: Sized](val: T) -> Int:
    return _len(val)
