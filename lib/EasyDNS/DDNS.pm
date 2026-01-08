package EasyDNS::DDNS;

use strict;
use warnings;

our $VERSION = '0.001';

sub new {
    my ($class, %args) = @_;
    return bless { %args }, $class;
}

1;

__END__

=pod

=head1 NAME

EasyDNS::DDNS - EasyDNS Dynamic DNS updater (library)

=head1 SYNOPSIS

  use EasyDNS::DDNS;

  my $ddns = EasyDNS::DDNS->new;

=head1 DESCRIPTION

Core library for the C<sdseasydyn> CLI. This distribution is intentionally
structured for testing, CI, and future release discipline.

=head1 AUTHOR

Sergio de Sousa <sergio@serso.com>

=head1 LICENSE

LGPL-2.1

=cut

