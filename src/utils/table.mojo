# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Nova Table."""

from .memory import UnsafePointer, memclr, memset, memcpy


# +----------------------------------------------------------------------------------------------+ #
# | Table
# +----------------------------------------------------------------------------------------------+ #
#
struct Table[T: AnyTrivialRegType]:
    """A heap allocated table.

    Parameters:
        T: The type of elements in the table.
    """

    # +------< Data >------+ #
    #
    var _data: UnsafePointer[T]
    var _cols: Int
    var _rows: Int

    # +------( Lifecycle )------+ #
    #
    @always_inline
    fn __init__(out self):
        self._data = UnsafePointer[T]()
        self._cols, self._rows = 0, 0

    @always_inline
    fn __init__[clear: Bool](out self, cols: Int, rows: Int):
        self._data = UnsafePointer[T].alloc(cols * rows)
        self._cols, self._rows = cols, rows

        @parameter
        if clear:
            memclr(self._data, cols * rows)

    @always_inline
    fn __init__(out self, cols: Int, rows: Int, *, fill: T):
        self.__init__[False](cols, rows)
        memset(self._data, fill, cols)

    @always_inline
    fn __init__(out self, cols: Int, rows: Int, *, rule: fn (Int, Int) -> T):
        self.__init__[False](cols, rows)
        for y in range(rows):
            for x in range(cols):
                (self._data + (y * cols) + x)[] = rule(x, y)

    @always_inline
    fn __copyinit__(mut self, other: Self):
        if other._data:
            self.__init__[False](other._cols, other._rows)
            memcpy(self._data, other._data, other._cols * other._rows)
        else:
            self = Self()

    @always_inline
    fn __moveinit__(mut self, owned other: Self):
        self._data = other._data
        self._cols = other._cols
        self._rows = other._rows

    @always_inline
    fn __del__(owned self):
        if self._data:
            self._data.free()

    # +------( Subscript )------+ #
    #
    @always_inline
    fn __getitem__(ref [_]self, col: Int, row: Int) -> ref [__origin_of(self)] T:
        return (self._data + (row * self._cols + col))[]

    @always_inline
    fn __getitem__(ref [_]self, ind: (Int, Int)) -> ref [__origin_of(self)] T:
        return self[ind[0], ind[1]]

    # +------( Operations )------+ #
    #
    @always_inline
    fn __bool__(self) -> Bool:
        return self._cols != 0 and self._rows != 0
