# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Defines a static set-ordering prototype."""

from blade.bit import PopIter

# TODO:
# fn powerset[T: Copyable & Movable, //](list: List[T]) -> List[List[T]]:
#     """Returns all possible subsets of the given set."""
#     # maybe faster to use powerset_bin to generate this as well
#     if len(list) == 0:
#         return List(List[T]())
#     var cs = List[List[T]]()
#     for c in powerset(list[1:]):
#         cs.append(c.copy())
#         cs.append(List(list[0].copy()) + c.copy())
#     return cs^


# +--------------------------------------------------------------------------+ #
# | Ordering
# +--------------------------------------------------------------------------+ #
#
trait Ordering:
    """Powerset ordering meta-type."""

    # +------( powerset )------+ #
    #
    @staticmethod
    fn powerset(n: Int) -> List[List[Int]]:
        """Lists the powerset of n, that is,
        the set containing all possible subsets of n elements.

        Each subset is represented as a list of indices."""
        ...

    @staticmethod
    fn powerset_bin(n: Int) -> List[Int]:
        """Lists the powerset of n, that is,
        the set containing all possible subsets of n elements.

        Each combination is represented as a binary set of bit flags,
        indicating their presence in the set."""
        ...

    @staticmethod
    fn power_rank(n: Int, comb: List[Int]) -> Int:
        """Gets the total order of a subset within the powerset of n elements.
        """
        ...

    @staticmethod
    fn power_rank_bin(n: Int, comb: Int) -> Int:
        """Gets the total order of a subset within the powerset of n elements.
        """
        ...

    @staticmethod
    fn power_unrank(n: Int, var idx: Int) -> List[Int]:
        """Returns the subset at position `idx` within the powerset of n elements.
        """
        ...

    @staticmethod
    fn power_unrank_bin(n: Int, var idx: Int) -> Int:
        """Returns the subset at position `idx` within the powerset of n elements.
        """
        ...

    @staticmethod
    fn grade(n: Int, idx: Int) -> Int:
        """Returns the number of elements in the subset at position `idx`."""
        ...

    # +------( combinations )------+ #
    #
    @staticmethod
    fn combinations(n: Int, r: Int, out result: List[List[Int]]):
        """Lists all possible combinations of `r` elements selected from a set `n`.

        Each combination is represented as a list of indices."""
        var num_combs = pascal(n, r)
        result = List[List[Int]](capacity=num_combs)
        var i = ~(-1 << r)
        while len(result) < num_combs:
            var l = List[Int](capacity=r)
            for bit_idx in PopIter(i):
                l.append(bit_idx + 1)
            result.append(l^)
            i = Self.next_bin(n, i)

    @staticmethod
    fn combinations_bin(n: Int, r: Int, out result: List[Int]):
        """Lists all possible combinations of `r` elements selected from a set `n`.

        Each combination is represented as a binary set of bit flags,
        indicating their presence in the set."""
        var num_combs = pascal(n, r)
        result = List[Int](capacity=num_combs)
        var i = ~(-1 << r)
        while len(result) < num_combs:
            result.append(i)
            i = Self.next_bin(n, i)

    @staticmethod
    fn rank(n: Int, comb: List[Int]) -> Int:
        """Gets the order of a combination within the set of
        possible combinations chosen from n elements.
        """
        ...

    @staticmethod
    fn rank_bin(n: Int, comb: Int) -> Int:
        """Gets the order of a combination within the set of
        possible combinations of n elements.
        """
        ...

    @staticmethod
    fn unrank(n: Int, var r: Int, var idx: Int) -> List[Int]:
        """Returns the combination at position `idx` within the set of
        possible combinations of n elements.
        """
        ...

    @staticmethod
    fn unrank_bin(n: Int, var r: Int, var idx: Int) -> Int:
        """Returns the combination at position `idx` within the set of
        possible combinations of n elements.
        """
        ...

    # +------( iteration )------+ #
    #
    @staticmethod
    fn next_bin(n: Int, bin: Int, out next_comb: Int):
        """Returns the combination immediately after `bin`,
        in the order defined by the subsumed type.
        """
        ...
