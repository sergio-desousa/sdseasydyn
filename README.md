# sdseasydyn

A small, cron-friendly EasyDNS Dynamic DNS updater.

## Highlights

- Updates one or more EasyDNS dynamic hostnames to your current public IP
- **Does nothing if IP did not change** (reduces API calls / avoids TOOSOON noise)
- Cron-friendly: predictable output and exit codes
- Retries transient HTTP failures using `Retry::Policy`

## Requirements

- Perl 5.30+
- `cpanm` recommended

## Install (from source)

```bash
cpanm --installdeps .
perl Makefile.PL
make test
```

Run:

```bash
perl -Ilib bin/sdseasydyn --help
```

## Configuration

Config file format is INI.

* Example: `examples/config.ini`
* Common location: `~/.config/sdseasydyn/config.ini`

Recommended: keep secrets in environment variables and reference them from config:

```ini
[easydns]
username = ${EASYDNS_USER}
token    = ${EASYDNS_TOKEN}
```

## Usage

See the operational guide:

* `docs/HOWTO.md`

## License

LGPL-2.1
