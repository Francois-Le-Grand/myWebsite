#!/usr/bin/perl -w

use Cwd;
use File::Find;
use strict;

my $directory = getcwd;
opendir (DIR, $directory) or die $!;

my @files = grep { /TD[1-9][a-zA-Z\.].+$/ } readdir(DIR);

for (@files){
    my $old = $_;
    s/TD/TD0/;
    rename($old, $_) or print "Error renaming: $old\n";
}

print @files;
