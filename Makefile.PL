
use strict;
use warnings;

BEGIN { require 5.008; }

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Add an AVAILABILITY pod section',
  'AUTHOR' => 'Marcel Gruenauer <marcel@cpan.org>, Nigel Metheringham <nigelm@cpan.org>, Mark Gardner <mjgardner@cpan.org>, Mike Doherty <doherty@cpan.org>',
  'BUILD_REQUIRES' => {
    'Carp' => '0',
    'English' => '0',
    'File::Find' => '0',
    'File::Temp' => '0',
    'Scalar::Util' => '0',
    'Test::More' => '0.94'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Pod-Weaver-Section-Availability',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Pod::Weaver::Section::Availability',
  'PREREQ_PM' => {
    'Dist::Zilla::Plugin::Bugtracker' => '0',
    'Dist::Zilla::Plugin::Homepage' => '0',
    'Moose' => '0',
    'Moose::Autobox' => '0',
    'Pod::Weaver::Role::Section' => '0',
    'namespace::autoclean' => '0'
  },
  'VERSION' => '1.110090',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



