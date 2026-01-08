# sdseasydyn

A small, cron-friendly EasyDNS Dynamic DNS updater.

## Status

Scaffold in progress. The `update` command is not implemented yet.

## Goals

- Safe, predictable CLI for updating one or more EasyDNS dynamic hostnames
- Resilient networking using `Retry::Policy` (exponential backoff + jitter)
- Tests + CI + disciplined release process

## License

LGPL-2.1 (see `LICENSE`)

