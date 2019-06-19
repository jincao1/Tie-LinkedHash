package Tie::LinkedHash;

use strict;
use warnings;
use parent "Tie::Hash";

our $VERSION = "0.1";

sub TIEHASH {
	my($c) = shift;
	my($s) = [];
	$s->[0] = {}; # hash-key index
	$s->[1] = [ # linked list
		0,     # list size
		undef, # head
		undef, # tail
	];
	$s->[2] = 0; # iter count

	if ($_[0] and ref($_[0]) eq "HASH") {
		my $cfg = shift(@_);
		if (!exists $cfg->{auto_tie}) {
			die "Tie::LinkedHash only accepts config options 'auto_tie'.";
		}
		$s->[3] = $cfg->{auto_tie};
	}

	bless $s, $c;

	while (@_) {
		$s->STORE(shift, shift);
	}

	return $s;
}


sub FETCH {
	my($s, $k) = (shift, shift);
	return exists( $s->[0]{$k} ) ? $s->[0]{$k}[3] : undef;
}


sub STORE {
	my($s, $k, $v) = (shift, shift, shift);

	if ($s->[3] and ref($v) eq "HASH") {
		# no order guarantee in initialization.
		# an empty hash should be used if initial order matters.
		tie(%$v, "Tie::LinkedHash", {auto_tie => 1}, %$v);
	}

	if (exists $s->[0]{$k}) {
		$s->[0]{$k}[3] = $v;
	}
	else {
		$s->[1][0]++;
		my $h = $s->[1][1];
		my $t = $s->[1][2];
		my $n = [$k, undef, undef, $v];

		if (defined $t) {
			$t->[2] = $n;
			$n->[1] = $t;
		}
		else {
			$s->[1][1] = $n;
		}
		$s->[1][2] = $n;

		$s->[0]{$k} = $n;
	}
}


sub DELETE {
	my($s, $k) = (shift, shift);

	if (exists $s->[0]{$k}) {
		my $n = delete($s->[0]{$k});
		$s->[1][0]--;
		$n->[1][2] = $n->[2];
		$n->[2][1] = $n->[1];
		if ($n == $s->[1][1]) {
			$s->[1][1] = $n->[2];
		}
		elsif ($n == $s->[1][2]) {
			$s->[1][2] = $n->[1];
		}
		return $n->[3];
	}
	return undef;
}


sub EXISTS {
	exists $_[0]->[0]{ $_[1] };
}


sub FIRSTKEY {
	$_[0][2] = $_[0][1][1]; # head
	&NEXTKEY;
}


sub NEXTKEY {
	my $n = $_[0][2];
	$_[0][2] = $n->[2];
	$n->[0];
}


sub CLEAR {
	my ($s) = @_;
	$s->[0] = {}; # hashkey index
	$s->[1] = [ # linked list
		0,     # list size
		undef, # head
		undef, # tail
	];
	$s->[2] = 0; # iter count
}

sub SCALAR {
	return $_[0]->[1][0];
}

sub size {
	my ($s) = @_;
	return $s->SCALAR();
}

sub print_list {
	my ($s) = @_;
	my $ls = $s->[1];
	my $head = $ls->[1];
	return if not defined $head;
	print $head->[0];
	while ($head->[2]) {
		$head = $head->[2];
		last if $head == $ls->[1];
		print " -> ";
		print $head->[0];
	}
	print "\n";
}

=head1 NAME

Tie::LinkedHash - Ordered Hashes



=head1 DESCRIPTION

This module implements an ordered hash using a linked list to track the order
that keys are entered. Use it when you need to keep the insertion orders of keys
in a hash.

Because this module implements a linked list, both inserts and deletes
are very fast and behaves more like a list. If delete speed is not an issue
you may consider using L<Tie::IxHash> as an alternative.

=head1 SYNOPSIS

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

  # fast way to get size (and if the hash contanis items).
  $bool = scalar %hash;
  $bool = (tied %hash)->size(); # ditto

=head1 CAVEATS

Since this implements a linked list, it is a lot more memory intensive than
using a pure Perl hash. Avoid tie-ing large data structures or enabling I<auto_tie>
if memory is going to be an issue.

If I<auto_tie> is enabled and you store a hash reference already with items in it
there will be no guarantee to the initial key order. All subsequent keys will be
added in order.

=head1 SEE ALSO

See L<Tie::LLHash> for an alternative to this module.

See L<Tie::IxHash> for a standard ordered hash, with slow deletes.

=head1 BUGS

You tell me.

=head1 AUTHOR

Jin Cao

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Jin Cao

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;