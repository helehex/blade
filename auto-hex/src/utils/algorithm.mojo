# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Algorithm."""


fn vectorize_raising[
    func: fn[width: Int] (Int) raises capturing -> None, width: Int
](count: Int) raises:
    var offset = 0
    var end = width
    while offset < count:
        func[width](offset)
        offset = end
        end += width
    while offset < count:
        func[1](offset)
        offset += 1


fn vectorize_stoping[func: fn[width: Int] (Int) capturing -> Bool, width: Int](count: Int) -> Bool:
    var offset = 0
    var end = width
    while end <= count:
        if func[width](offset):
            return True
        offset = end
        end += width
    while offset < count:
        if func[1](offset):
            return True
        offset += 1
    return False
