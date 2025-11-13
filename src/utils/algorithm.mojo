# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Algorithms."""


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


fn counted_sort(mut basis: List[Int]) -> Int:
    var count = 0
    for i in range(1, len(basis)):
        var j = i
        while j > 0 and basis[j] < basis[j - 1]:
            count += 1
            var temp = basis[j - 1]
            basis[j - 1] = basis[j]
            basis[j] = temp
            j -= 1
    return count


fn count_odd(array: List[Int]) -> Int:
    var count = 0
    var i = 1
    var m = 0
    while i < len(array):
        if array[i - 1] != array[i]:
            if i % 2 != m:
                count += 1
            m = i % 2
        i += 1

    if len(array) % 2 != m:
        count += 1

    return count
