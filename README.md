# Tie-LinkedHash

Ordered associative array in pure Perl with fast key deletes.

```perl
  use Tie::LinkedHash;

  # A new empty hash
  tie(%x, 'Tie::LinkedHash');

  # A new empty hash with items
  tie(%y, 'Tie::LinkedHash', "a" => 1, "b" => 2);

  # A new empty hash, where all nested hash references are tied to Tie::LinkedHash
  tie(%z, 'Tie::LinkedHash', { auto_tie => 1});
  $z{a} = {}; # the value will be auto tied to Tie::LinkedHash
  
  # DO NOT DO THIS if order of the values matter.
  # The order of the value hash will not be guaranteed. Only subsequent insertions
  # will be in order!
  $z{b} = { 'x' => 1, 'y' => 2, 'z' => 3 }
  

  # To determine the number of keys in the hash (or if the hash has items)
  # bad, very slow for large hashes!!
  $bool = scalar keys %hash;

  # scalar context, no issues.
  if (%hash) { ... }

  # fast way to get size (and if the hash contains items).
  $bool = scalar %hash;
  $bool = (tied %hash)->size(); # ditto
```
