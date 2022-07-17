# neouuid

Fast and idiomatic UUIDs (Universally Unique Identifiers) in Dart.

[![Style guide][sty_img]][sty_url]

[sty_url]: https://pub.dev/packages/neodart
[sty_img]: https://img.shields.io/badge/style-neodart-9cf.svg

This library generates UUIDs, 128-bits represented as 32 hexadecimal digits:

```txt
ba6eb330-4f7f-11eb-a2fb-67c34e9ac07c
```

## Usage

The generator supports three different [UUID][] modes:

- `v1`: Guaranteed unique, unless generated from the _same_ computer at the
  _same_ time.
- `v4`: Completely random, `2^128` possible combinations make it almost
  impossible to repeat.
- `v5`: Non-random, generateed by providing an _input_ and _namespace_ string.

[uuid]: https://tools.ietf.org/html/rfc4122.html
[v1]: https://datatracker.ietf.org/doc/html/rfc4122

## Contributing

Some inspiration:

- <https://github.com/uuidjs/uuid>
