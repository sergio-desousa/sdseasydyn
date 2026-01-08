package EasyDNS::DDNS;

use strict;
use warnings;

our $VERSION = '0.001';

use EasyDNS::DDNS::Config ();

sub new {
    my ($class, %args) = @_;
    return bless {
        verbose => $args{verbose} // 0,
    }, $class;
}

sub cmd_update {
    my ($self, %args) = @_;

    my $cfg = EasyDNS::DDNS::Config->load(
        config_path => $args{config_path},
        env         => \%ENV,
        cli         => {
            hosts      => $args{hosts},
            state_path => $args{state_path},
            ip         => $args{ip},
            ip_url     => $args{ip_url},
            timeout    => $args{timeout},
        },
    );

    if (!$cfg->{ok}) {
        return $cfg;
    }

    my $hosts = $cfg->{resolved}{hosts} || [];
    if (!@$hosts) {
        return {
            ok        => 0,
            exit_code => 2,
            error     => "No hostnames provided. Use --host or set [update] hosts in config.",
        };
    }

    # Step 4 ends here: plumbing only (HTTP/State will be exercised via tests).
    return {
        ok       => 1,
        resolved => $cfg->{resolved},
    };
}

1;

__END__

=pod

=head1 NAME

EasyDNS::DDNS - EasyDNS Dynamic DNS updater (library)

=head1 DESCRIPTION

Core library for the C<sdseasydyn> CLI. This distribution is intentionally
structured for testing, CI, and future release discipline.

=head1 AUTHOR

Sergio de Sousa <sergio@serso.com>

=head1 LICENSE

LGPL-2.1

=cut

