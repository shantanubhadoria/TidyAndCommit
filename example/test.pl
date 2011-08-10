#!/usr/bin/perl
use strict;
use warnings;
use TidyAndCommit;

my $tncobj = TidyAndCommit->new(
                         perltidyrc => './xt/.perltidyrc',
                         runbefore  => 'svn commit' # The command to call on the list post commit
                           );
my @list; # List of files and folders to be tidied and committed
push @list,'./'; 
$tncobj->tnc(\@list); # If you want to pass a list of files or folders to the script to tidy and then commit, you might simply use the @ARGV array instead of @list here. Once you do that this script will essentially work as a wrapper around the command "svn commit" passed as "runbefore" param above you can further modify this script to support -m flags for commit messages etc. if your SVN_EDITOR is not set.
