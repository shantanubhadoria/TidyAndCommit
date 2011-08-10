package TidyAndCommit;

use 5.006;
use strict;
use warnings;

=head1 NAME

TidyAnyCommit - This class can be used as a wrapper around a commit (check example for how to wrap 
this around a subversion commit message). The module cleans up the target code using perltidy before 
running the next step(usually a svn commit statement for my own use case). Perltidy must be 
installed before use of this script. This Class will Tidy all files with .pm, .cgi or .pl extension 
when passed a file name and it will search for all file in a folder with .pm, .cgi or .pl extension
when passed a foldername pass your own tidyrc config file to the object to get custom tidy goodness.

=head1 SYNOPSIS

  use strict;
  use warnings;
  use TidyAndCommit;

  my $tncobj = TidyAndCommit->new(
                           perltidyrc => './xt/.perltidyrc',
                           runbefore  => 'svn commit' # The command to call on the list post commit
                             );
  my @list; # List of files and folders to be tidied and committed
  push @list,'./'; 
  $tncobj->tnc(\@list); # \@list is a list of absolute or relative paths to files and folders.
                        #
                        # If you want to pass a list of files or folders to the script to tidy and
                        # then commit, you might simply use the @ARGV array instead of @list here. 
                        # Once you do that this script will essentially work as a wrapper around 
                        # the command "svn commit" passed as "runbefore" param above you can further 
                        # modify this script to support -m flags for commit messages etc. 
                        # if your SVN_EDITOR is not set.

=cut

use Perl::Tidy;
use File::Spec qw//;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'all' => [
        qw(

            )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( );


sub new {
    my ( $this,%params) = @_;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;

    if ( exists($params{perltidyrc}) ) {
        $self->{perltidyrc} = $params{perltidyrc};
    }
    if ( exists($params{temppath}) ) {
        $self->{temppath} = $params{temppath};
    }
    else {
        $self->{temppath} = File::Spec->catfile(File::Spec->tmpdir(),'tmp.pl');
    }
    if ( exists($params{runbefore}) ) {
        $self->{runbefore} = $params{runbefore};
    }

    return $self;
}

sub tnc {
    my ( $self, $list ) = @_;
    my $aggregatedPath = '';
    my @files = @$list;
    @ARGV = undef;
    while ( my $path = shift @files) {
    print " Param passed $path\n";
    if ( -d $path ) {
        my $path2 = $path;
    $path2 =~ s/\s/\\ /g;
        $aggregatedPath .= "$path2 ";
        my $fileslist = `find $path`;
        for my $file ( split( /\n/, $fileslist ) ) {
            if ( $file =~ /\.[cp][glm]i?$/i ) {
                print "Tidying $file\n";
                Perl::Tidy::perltidy(
                    argv           => $file,
                    perltidyrc     => $self->{perltidyrc},
                );
            }
        }
    }
    elsif ( -f $path ) {
        my $path2 = $path;
    $path2 =~ s/\s/\\ /g;
        $aggregatedPath .= "$path2 ";
        if ( $path =~ /\.[cp][glm]i?$/i ) {
            print "Tidying $path\n";
                Perl::Tidy::perltidy(
                    argv => $path,
                    perltidyrc        => $self->{perltidyrc},
                );
        }
    }
    else {
        print STDERR "Error : Not a file or folder : $path\n";
    }
}
# If all else went well go  ahead and commit
print $self->{runbefore}." $aggregatedPath\n";
exec $self->{runbefore}." $aggregatedPath";

}

1;    # End of TidyAndCommit 
__END__


=head1 AUTHOR

Shantanu Bhadoria, C<< <shantanu (dot comes here) bhadoria at gmail dot com> >> L<http://www.shantanubhadoria.com>.

=head1 BUGS

Please report any bugs or feature requests to C<bug-tidyandcommit at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TidyAndCommit>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc TidyAndCommit 

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=TidyAndCommit>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/TidyAndCommit>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/TidyAndCommit>

=item * Search CPAN

L<http://search.cpan.org/dist/TidyAndCommit/>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 Shantanu Bhadoria  

C<< <shantanu (dot comes here) bhadoria at gmail dot com> >> L<http://www.shantanubhadoria.com>

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 Dependencies 

File::Spec

Perl::Tidy

=cut

