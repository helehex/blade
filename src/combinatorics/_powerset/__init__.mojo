# +----------------------------------------------------------------------------------------------+ #
# | Powerset
# +----------------------------------------------------------------------------------------------+ #
#
"""Powerset implementations and orderings."""

from ._ordering import Ordering
from .slexic_ordering import SlexicOrdering
from .binary_ordering import BinaryOrdering


alias DefaultOrder = SlexicOrdering
alias powerset[Order: Ordering = DefaultOrder] = Order.powerset
alias powerset_bin[Order: Ordering = DefaultOrder] = Order.powerset_bin
alias power_rank[Order: Ordering = DefaultOrder] = Order.power_rank
alias power_rank_bin[Order: Ordering = DefaultOrder] = Order.power_rank_bin
alias power_unrank[Order: Ordering = DefaultOrder] = Order.power_unrank
alias power_unrank_bin[Order: Ordering = DefaultOrder] = Order.power_unrank_bin
alias grade[Order: Ordering = DefaultOrder] = Order.grade
alias combinations[Order: Ordering = DefaultOrder] = Order.combinations
alias combinations_bin[Order: Ordering = DefaultOrder] = Order.combinations_bin
alias rank[Order: Ordering = DefaultOrder] = Order.rank
alias rank_bin[Order: Ordering = DefaultOrder] = Order.rank_bin
alias unrank[Order: Ordering = DefaultOrder] = Order.unrank
alias unrank_bin[Order: Ordering = DefaultOrder] = Order.unrank_bin
