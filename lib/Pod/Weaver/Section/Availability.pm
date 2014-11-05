use 5.008;
use strict;
use warnings;

package Pod::Weaver::Section::Availability;
BEGIN {
  $Pod::Weaver::Section::Availability::VERSION = '1.110090';
}

# ABSTRACT: Add an AVAILABILITY pod section
use Moose;
with 'Pod::Weaver::Role::Section';
use namespace::autoclean;
use Moose::Autobox;

# add a set of attributes to hold the repo information
has zilla =>
  (is => 'rw', isa => 'Dist::Zilla', handles => [ 'name', 'distmeta' ]);
has [qw(homepage_url cpan_url repo_type repo_url)] =>
  (is => 'rw', isa => 'Str', lazy_build => 1);
has repo_web => (is => 'rw', lazy_build => 1);
has is_github => (is => 'rw', isa => 'Bool', lazy_build => 1);

sub weave_section {
    my ($self, $document, $input) = @_;
    $self->zilla($input->{zilla});
    my @pod = ($self->_homepage_pod, $self->_cpan_pod);

    # Non-github repos may not have a repo web URL
    if ($self->repo_web) {
        push @pod, $self->_development_pod;
    }
    $document->children->push(
        Pod::Elemental::Element::Nested->new(
            {   command  => 'head1',
                content  => 'AVAILABILITY',
                children => \@pod,
            }
        ),
    );
}

sub _build_homepage_url {
    my $self = shift;
    $self->distmeta->{resources}{homepage}
      || sprintf 'http://search.cpan.org/dist/%s/', $self->name;
}

sub _build_cpan_url {
    sprintf 'http://search.cpan.org/dist/%s/', shift->name;
}

# if we don't know we default to git...
sub _build_repo_type {
    shift->distmeta->{resources}{repository}{type} || 'git';
}

sub _build_repo_url {
    (shift->_build_repo_data)[0];
}

sub _build_repo_web {
    (shift->_build_repo_data)[1];
}

sub _build_is_github {
    my $self = shift;

    # we do this by looking at the URL for githubbyness
    my $repourl = $self->distmeta->{resources}{repository}{url}
      or die "No repository URL set in distmeta";
    $repourl =~ m|/github.com/|;
}

sub _build_repo_data {
    my $self    = shift;
    my $repourl = $self->distmeta->{resources}{repository}{url}
      or die "No repository URL set in distmeta";
    my $repoweb;
    if ($self->is_github) {

        # strip the access method off - we can then add it as needed
        my $nomethod = $repourl;
        $nomethod =~ s{^(http|git|git\@github\.com):/*}{}i;
        $nomethod =~ s{\.git$}{}i;
        $repourl = "git://$nomethod.git";
        $repoweb = "http://$nomethod";
    }
    return ($repourl, $repoweb);
}

sub _homepage_pod {
    my $self = shift;

    # we suppress this if the CPAN URL is the homepage URL
    return if $self->cpan_url eq $self->homepage_url;

    # otherwise return some boilerplate
    Pod::Elemental::Element::Pod5::Ordinary->new(
        {   content => sprintf 'The project homepage is L<%s>.',
            $self->homepage_url
        }
    );
}

sub _cpan_pod {
    my $self = shift;
    my $text = sprintf
      "%s\n%s\n%s L<%s>.",
'The latest version of this module is available from the Comprehensive Perl',
'Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN',
      'site near you, or see',
      $self->cpan_url;
    Pod::Elemental::Element::Pod5::Ordinary->new({ content => $text });
}

sub _development_pod {
    my $self = shift;
    my $text;
    if ($self->is_github) {
        $text = sprintf "The development version lives at L<%s>\n",
          $self->repo_web;
        $text .= sprintf "and may be cloned from L<%s>.\n", $self->repo_url;
        $text .=
"Instead of sending patches, please fork this project using the standard\n";
        $text .= "git and github infrastructure.\n";
    } else {
        $text =
          sprintf "The development version lives in a %s repository at L<%s>\n",
          $self->repo_type, $self->repo_web;
    }
    Pod::Elemental::Element::Pod5::Ordinary->new({ content => $text });
}
1;


__END__
=pod

=for test_synopsis 1;
__END__

=head1 NAME

Pod::Weaver::Section::Availability - Add an AVAILABILITY pod section

=head1 VERSION

version 1.110090

=head1 SYNOPSIS

In C<weaver.ini>:

    [Availability]

=head1 OVERVIEW

This section plugin will produce a hunk of Pod that refers the user to the
distribution's homepage and development versions.

You need to use L<Dist::Zilla::Plugin::Bugtracker> and
L<Dist::Zilla::Plugin::Homepage> in your C<dist.ini> file, because
this plugin relies on information those other plugins generate.

=head1 METHODS

=head2 weave_section

Adds the C<AVAILABILITY> section.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org/Public/Dist/Display.html?Name=Pod-Weaver-Section-Availability>.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<http://search.cpan.org/dist/Pod-Weaver-Section-Availability/>.

The development version lives at L<http://github.com/hanekomu/Pod-Weaver-Section-Availability.git>
and may be cloned from L<git://github.com/hanekomu/Pod-Weaver-Section-Availability.git>.
Instead of sending patches, please fork this project using the standard
git and github infrastructure.

=head1 AUTHORS

=over 4

=item *

Marcel Gruenauer <marcel@cpan.org>

=item *

Nigel Metheringham <nigelm@cpan.org>

=item *

Mark Gardner <mjgardner@cpan.org>

=item *

Mike Doherty <doherty@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Marcel Gruenauer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

