
# Source : https://oj.leetcode.com/problems/3sum-closest/
# Author : sxw2k
# Date   : 2016-03-07

#`(
* Given an array S of n integers, find three integers in S such that the sum is
* closest to a given number, target. Return the sum of the three integers.
* You may assume that each input would have exactly one solution.
*
*     For example, given array S = {-1 2 1 -4}, and target = 1.
*
*     The sum that is closest to the target is 2. (-1 + 2 + 1 = 2).
*
)

use v6;

sub MAIN(:t(:$target), *@array) {
    my %hash = @array.combinations(3).classify((*.sum - $target).abs);
    for %hash.keys.min -> $key {
        for %hash{$key}.list -> $list {
            say "{$list.sum} =>\t $list";
        }
    }
}
