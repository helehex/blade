# +--------------------------------------------------------------------------+ #
# | Powerset
# +--------------------------------------------------------------------------+ #
#
"""Powerset implementations and orderings."""

from ._ordering import Ordering
from .slexic_ordering import SlexicOrdering
from .binary_ordering import BinaryOrdering


comptime DefaultOrder: Ordering = SlexicOrdering
comptime powerset[Order: Ordering = DefaultOrder] = Order.powerset
comptime powerset_bin[Order: Ordering = DefaultOrder] = Order.powerset_bin
comptime power_rank[Order: Ordering = DefaultOrder] = Order.power_rank
comptime power_rank_bin[Order: Ordering = DefaultOrder] = Order.power_rank_bin
comptime power_unrank[Order: Ordering = DefaultOrder] = Order.power_unrank
comptime power_unrank_bin[Order: Ordering = DefaultOrder] = Order.power_unrank_bin
comptime grade[Order: Ordering = DefaultOrder] = Order.grade
comptime combinations[Order: Ordering = DefaultOrder] = Order.combinations
comptime combinations_bin[Order: Ordering = DefaultOrder] = Order.combinations_bin
comptime rank[Order: Ordering = DefaultOrder] = Order.rank
comptime rank_bin[Order: Ordering = DefaultOrder] = Order.rank_bin
comptime unrank[Order: Ordering = DefaultOrder] = Order.unrank
comptime unrank_bin[Order: Ordering = DefaultOrder] = Order.unrank_bin
