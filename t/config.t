use strict;
use warnings;

use Test2::V0;

use File::Temp qw/tempdir/;
use File::Spec ();

use EasyDNS::DDNS::Config;

my $tdir = tempdir(CLEANUP => 1);
my $cfgd = File::Spec->catdir($tdir, 'sdseasydyn');
mkdir $cfgd or die "mkdir: $!" if !-d $cfgd;

my $cfg = File::Spec->catfile($cfgd, 'config.ini');

_write_file($cfg, <<'INI');
[easydns]
username = cfg_user
token    = cfg_token

[update]
hosts = a.example.com, b.example.com
ip_url = https://example.test/ip
timeout = 20
INI

my %env = (
    EASYDNS_USER  => 'env_user',
    EASYDNS_TOKEN => 'env_token',
);

# CLI empty -> ENV beats config for creds, config supplies hosts/ip_url/timeout
{
    my $r = EasyDNS::DDNS::Config->load(
        config_path => $cfg,
        env         => \%env,
        cli         => {
            hosts   => [],
            ip      => '',
            ip_url  => '',
            timeout => 0,
        },
    );

    ok($r->{ok}, 'config load ok');
    is($r->{resolved}{username}, 'env_user', 'ENV username wins');
    is($r->{resolved}{token_set}, 1, 'token_set true');
    is($r->{resolved}{ip_url}, 'https://example.test/ip', 'config ip_url');
    is($r->{resolved}{timeout}, 20, 'config timeout');
    is($r->{resolved}{hosts}, [qw/a.example.com b.example.com/], 'hosts from config');
}

# CLI hosts should win over config
{
    my $r = EasyDNS::DDNS::Config->load(
        config_path => $cfg,
        env         => \%env,
        cli         => {
            hosts   => ['cli.example.com'],
            ip      => '',
            ip_url  => '',
            timeout => 0,
        },
    );

    ok($r->{ok}, 'config load ok');
    is($r->{resolved}{hosts}, ['cli.example.com'], 'hosts from CLI');
}

# CLI ip_url and timeout win over config/defaults
{
    my $r = EasyDNS::DDNS::Config->load(
        config_path => $cfg,
        env         => \%env,
        cli         => {
            hosts   => [],
            ip      => '',
            ip_url  => 'https://cli.test/ip',
            timeout => 7,
        },
    );

    ok($r->{ok}, 'config load ok');
    is($r->{resolved}{ip_url}, 'https://cli.test/ip', 'CLI ip_url wins');
    is($r->{resolved}{timeout}, 7, 'CLI timeout wins');
}

done_testing;

sub _write_file {
    my ($path, $content) = @_;
    open my $fh, '>', $path or die "open($path): $!";
    print {$fh} $content or die "write($path): $!";
    close $fh or die "close($path): $!";
}

