# Ngrok

Crystal wrapper for Ngrok

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  ngrok:
    github: watzon/ngrok
```

## Usage

```crystal
require "ngrok"

ngrok = Ngrok.start

# ngrok address
ngrok.addr
# => "127.0.0.1:3001"

# ngrok external url
ngrok.ngrok_url
# => "http://aaa0e65.ngrok.io"

ngrok.ngrok_url_https
# => "https://aaa0e65.ngrok.io"

ngrok.running?
# => true

ngrok.stopped?
# => false

# ngrok process id
ngrok.pid
# => 27384

# keep the connection alive
sleep
```

```crystal
Ngrok.start(addr: 'foo.dev:80',
            subdomain: 'MY_SUBDOMAIN',
            hostname: 'MY_HOSTNAME',
            authtoken: 'MY_TOKEN',
            inspect: false,
            log: File.open("./log.txt", "w"),
            config: '~/.ngrok')
```

## Contributing

1. Fork it ( https://github.com/watzon/ngrok/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [watzon](https://github.com/watzon) Chris Watson - creator, maintainer
