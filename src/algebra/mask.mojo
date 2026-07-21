# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Helper struct for basis masking."""

from std.bit import next_power_of_two

from src.combinatorics import power_unrank_bin, SlexicOrdering

from .basis import Basis


@fieldwise_init
struct BasisMask(Copyable, Movable, Sized):
    var full: Int
    var entries: List[Basis]

    @always_inline
    def __init__(out self, *, full: Int = -1, capacity: Int = 0):
        self.full = full
        self.entries = List[Basis](capacity=capacity)

    @always_inline
    def __init__(out self, *bases: Basis):
        self = Self(capacity=len(bases))
        for basis in bases:
            self.unmask(basis)

    def copy(self) -> Self:
        return Self(self.full, self.entries.copy())

    @always_inline
    def unmask(mut self, basis: Basis):
        for idx in range(len(self.entries)):
            if self.entries[idx] < basis:
                continue
            elif self.entries[idx] == basis:
                return
            else:
                self.entries.insert(idx, basis)
                return
        self.entries.append(basis)

    @always_inline
    def get_basis(self, entry: Int) -> Basis:
        if self.full == -1:
            return self.entries[entry]
        return Basis(bin=power_unrank_bin[SlexicOrdering](self.full, entry))

    @always_inline
    def get_entry(self, basis: Basis) -> Int:
        if self.full != -1:
            return basis.bin

        for idx in range(len(self.entries)):
            if self.entries[idx] < basis:
                continue
            elif self.entries[idx] == basis:
                return idx
            else:
                break
        return -1

    @always_inline
    def __len__(self) -> Int:
        return (2**self.full) if self.full != -1 else len(self.entries)

    @always_inline
    def __or__(lhs, rhs: Self, out result: Self):
        result = Self(capacity=len(lhs.entries))
        var lhs_idx = 0
        var rhs_idx = 0

        while True:
            if lhs_idx < len(lhs.entries) and (
                rhs_idx >= len(rhs.entries)
                or lhs.entries[lhs_idx] < rhs.entries[rhs_idx]
            ):
                result.entries.append(lhs.entries[lhs_idx])
                lhs_idx += 1
            elif rhs_idx < len(rhs.entries) and (
                lhs_idx >= len(lhs.entries)
                or lhs.entries[lhs_idx] > rhs.entries[rhs_idx]
            ):
                result.entries.append(rhs.entries[rhs_idx])
                rhs_idx += 1
            elif lhs_idx < len(lhs.entries) and rhs_idx < len(rhs.entries):
                result.entries.append(lhs.entries[lhs_idx])
                lhs_idx += 1
                rhs_idx += 1
            else:
                return
