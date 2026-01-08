package EasyDNS::DDNS::Config;

use strict;
use warnings;

use Config::Tiny;
use File::Spec ();
use File::Basename ();
use Cwd ();

sub load {
    my ($class, %args) = @_;

    my $env = $args{env} || {};
    my $cli = $args{cli} || {};

    my $default_path = _default_config_path();
    my $path = $args{config_path};
    $path = $default_path if !defined($path) || $path eq '';

    $path = _expand_tilde($path);

    my $ini = {};
    if (-f $path) {
        my $ct = Config::Tiny->read($path);
        if (!$ct) {
            return {
                ok        => 0,
                exit_code => 2,
                error     => "Failed to read config '$path': " . Config::Tiny->errstr,
            };
        }
        $ini = $ct;
    }

    # Extract config values
    my $cfg_user   = _trim($ini->{easydns}{username} // '');
    my $cfg_token  = _trim($ini->{easydns}{token}    // '');

    my $cfg_hosts  = _trim($ini->{update}{hosts}     // '');
    my $cfg_ip_url = _trim($ini->{update}{ip_url}    // '');
    my $cfg_timeout= _trim($ini->{update}{timeout}   // '');

    # Allow ${ENVVAR} expansion in config values
    $cfg_user   = _expand_env($cfg_user,  $env);
    $cfg_token  = _expand_env($cfg_token, $env);
    $cfg_ip_url = _expand_env($cfg_ip_url,$env);

    my @hosts_from_cfg = _split_hosts($cfg_hosts);

    # ENV values
    my $env_user  = _trim($env->{EASYDNS_USER}  // '');
    my $env_token = _trim($env->{EASYDNS_TOKEN} // '');

    # CLI values
    my @hosts_from_cli = ();
    if ($cli->{hosts} && ref($cli->{hosts}) eq 'ARRAY') {
        # Getopt may deliver array-of-arrays if invoked oddly; normalize
        for my $h (@{ $cli->{hosts} }) {
            if (ref $h eq 'ARRAY') {
                push @hosts_from_cli, @$h;
            } else {
                push @hosts_from_cli, $h;
            }
        }
        @hosts_from_cli = grep { defined($_) && $_ ne '' } @hosts_from_cli;
    }

    my $cli_ip      = _trim($cli->{ip}      // '');
    my $cli_ip_url  = _trim($cli->{ip_url}  // '');
    my $cli_timeout = $cli->{timeout};

    # Defaults
    my $def_ip_url  = 'https://api.ipify.org';
    my $def_timeout = 10;

    # Precedence: CLI > ENV > config > defaults
    my $username = $env_user  || $cfg_user;
    my $token    = $env_token || $cfg_token;

    my @hosts = @hosts_from_cli ? @hosts_from_cli : @hosts_from_cfg;

    my $ip_url  = $cli_ip_url || $cfg_ip_url || $def_ip_url;

    my $timeout = $def_timeout;
    if (defined $cfg_timeout && $cfg_timeout ne '' && $cfg_timeout =~ /^\d+$/) {
        $timeout = int($cfg_timeout);
    }
    if (defined $cli_timeout && $cli_timeout =~ /^\d+$/ && $cli_timeout > 0) {
        $timeout = int($cli_timeout);
    }

    my $resolved = {
        config_path => $path,
        username    => $username,
        token_set   => ($token ? 1 : 0),   # do not expose token
        hosts       => \@hosts,
        ip          => $cli_ip,
        ip_url      => $ip_url,
        timeout     => $timeout,
    };

    return { ok => 1, resolved => $resolved };
}

sub _default_config_path {
    my $home = $ENV{HOME} || Cwd::getcwd();
    return File::Spec->catfile($home, '.config', 'sdseasydyn', 'config.ini');
}

sub _expand_tilde {
    my ($path) = @_;
    return $path if !defined $path || $path eq '';
    return $path if $path !~ m{^~(/|$)};
    my $home = $ENV{HOME} || '';
    $path =~ s{^~}{$home};
    return $path;
}

sub _expand_env {
    my ($s, $env) = @_;
    return $s if !defined $s;
    $s =~ s/\$\{([A-Z0-9_]+)\}/exists $env->{$1} ? $env->{$1} : ''/ge;
    return $s;
}

sub _split_hosts {
    my ($s) = @_;
    return () if !defined($s) || $s eq '';
    my @h = split /\s*,\s*/, $s;
    @h = map { _trim($_) } @h;
    @h = grep { $_ ne '' } @h;
    return @h;
}

sub _trim {
    my ($s) = @_;
    return '' if !defined $s;
    $s =~ s/^\s+//;
    $s =~ s/\s+$//;
    return $s;
}

1;

__END__

=pod

=head1 NAME

EasyDNS::DDNS::Config - Configuration handling for sdseasydyn

=head1 DESCRIPTION

Loads configuration from (in precedence order):

  CLI > ENV > config file > defaults

Config file format is INI (Config::Tiny).

=cut

