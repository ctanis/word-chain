#!/usr/bin/perl -w

# Small script for generating word chains using /usr/share/dict/words (MacOS
# and others).
#
# Usage: word-chain.pl start finish maxlen <words to ignore>
#
# Note: the system dictionary has some crazy-ass words in it, so I made a word
# list like so:
# > aspell dump master > aspell-words.txt
#
#
# Example:  BRAIN to THINK in 7 (multiple runs provided list of nonsense words to ignore)
#
# > ./word-chain.pl brain think 7
# going from brain to think in 7
# brain train trait tract track trick thick think


use strict;



my ($start,$finish, $max, @ignore) = map lc, @ARGV;

#my $wordfile='/usr/share/dict/words';
my $wordfile='./aspell-words.txt';
my %words;
open WORDS,$wordfile or die;

while (<WORDS>) {
  chomp;
  $words{lc $_}=1 unless /[A-Z]/; # skip proper nouns?
}

unless (exists $words{$finish}) {
  print STDERR "$finish is not in the dictionary\n";
  exit;
}

print STDERR "going from $start to $finish in $max\n";


sub next_rung($@) {
  my ($s,@ignore)=@_;
  my @alpha=qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
  my @l = split '', $s;
  # local $"="**";
  my $p;
  my @next=();

  for ($p=0; $p<scalar @l; $p++) {
    for ($a=0; $a<26; $a++) {
      my @stablets = @l;
      $stablets[$p]=$alpha[$a];

      local $"="";
      my $stab="@stablets";
      #print STDERR "stab: $start -> $stab\n";

      if (exists $words{$stab} and $stab ne $start) {
        #print STDERR "stab: $start -> $stab @ignore", grep {$_ eq $stab} @ignore, "\n";        
        push @next, $stab unless grep {$_ eq $stab} @ignore;
      }
    }
  }

  # print STDERR "$s -> @next\n";
  return @next;

}
  
sub build_ladder {
  my ($start,$finish,$max,@ignore) = @_;
  my $rval={};

  return if $max <= 0;

  my @next=next_rung($start, @ignore);

  for my $n (@next) {
    if ($n eq $finish) {
      return "$n";
    }
    else {
      push @ignore, $n;
      my $z= build_ladder($n,$finish,$max-1, @ignore);
      $rval->{$n}=$z if $z;
      pop @ignore;
    }
  }

  if (%$rval) {
    return $rval;
  }
  else {
    return 0;
  }
}


sub print_tree {
  my ($root, $parents) = @_;

  if (ref $root) {
    for my $k (keys %$root) {
      print_tree ($root->{$k}, "$parents $k");
    }
  }  
  else {
    print "$parents $root\n";
  }
}


my @chains=build_ladder($start,$finish,$max, @ignore);

for my $c (@chains) {
  print_tree($c, "$start");
}

# use  Data::Dumper;
# print Dumper(\@chain);
