# Ngrok

[![Github Actions](https://github.com/watzon/ngrok.cr/workflows/Crystal/badge.svg)](https://github.com/watzon/ngrok.cr/workflows/Crystal) ![license](https://img.shields.io/github/license/watzon/ngrok.cr.svg)

Crystal wrapper for ngrok. This library does not require ngrok be installed as it includes a downloaded which will go and fetch the version of ngrok for your system and save it locally. If you do have ngrok installed it will use the installed version.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  ngrok:
    github: watzon/ngrok.cr
```

## Usage

### Authenticate with Ngrok

```crystal
Ngrok.auth("your token")
```

### Start an Ngrok Session

```crystal
Ngrok.start(addr: "127.0.0.1:3001",
            subdomain: nil,
            hostname: nil,
            timeout: 10.seconds,
            inspect: false,
            region: "us",
            config: nil,
            use_local_executable: true,
            ngrok_bin: "./bin") do |ngrok|
  # `ngrok.url` contains the http url for this session
  puts ngrok.url

  # `ngrok.url_https` contains the https url for this session
  puts ngrok.url_https
end
```

## Usage Examples

See the `examples` directory for a couple usage examples.

## Contributing

1. Fork it ( https://github.com/watzon/ngrok.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [watzon](https://github.com/watzon) Chris Watson - creator, maintainer
