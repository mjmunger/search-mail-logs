# Search Email Logs

## Summary
This script grabs all the available logs on a mail server, concatenates them into a single file for search - gunzipping
where appropriate.

Once the script runs, it creates a directory: `/tmp/maillog`, which it uses for operations.
Inside that directory, it creates `search.log`, which is the concatenated log files pulled for use.

Subsequent searches will use the `search.log` file by default. So, if you need to reload or refresh the data,
use the `-r` option.

## Options

Syntax:
  search-email-logs.sh [option] [string]

Options:
  -r        Reload and reconcatenated the log files.
  -d        Search for delivered emails (Status=250 OK)
  -w        Search for whitelisted emails
  -j        Search for rejected emails
  -h        Show this help screen.

## Example

The example below searches all available email logs for `example.org`
```
search-email-logs example.org
```

## Configuration

The `/etc/mailsearch/mailsearch.conf` can be used to set various settings. As of now, they are:

### WHITELISTSTRING

Define what string constitutes a whitelist accept.
Example:
```
WHITELISTSTRING=triggers FILTER whitelist
```