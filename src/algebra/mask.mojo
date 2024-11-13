# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #


struct BasisMask:
    var entry_count: Int
    var basis2entry: List[Int]
    var entry2basis: List[Int]

    fn __init__(out self, mask: List[Bool]):
        self.entry_count = 0
        self.basis2entry = List[Int](capacity=len(mask))
        self.entry2basis = List[Int](capacity=len(mask))
        for basis in range(len(mask)):
            if mask[basis]:
                self.entry2basis += basis
                self.basis2entry += self.entry_count
                self.entry_count += 1
            else:
                self.basis2entry += -1

    fn __or__(lhs, rhs: Self) -> Self:
        var result = List[Bool](capacity=len(lhs.basis2entry))
        for idx in range(len(lhs.basis2entry)):
            result += (lhs.basis2entry[idx] != -1) | (rhs.basis2entry[idx] != -1)
        return result

    fn mul(lhs, rhs: Self, sig: Signature) -> Self:
        var result = sig.empty_mask()
        for x in lhs.entry2basis:
            for y in rhs.entry2basis:
                result[sig.mult[x[], y[]].basis] |= sig.mult[x[], y[]].sign != 0
        return result
