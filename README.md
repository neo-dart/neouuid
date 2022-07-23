# neouuid

Fast and idiomatic UUIDs (Universally Unique Identifiers) in Dart.

[![Binary on pub.dev][pub_img]][pub_url]
[![Code coverage][cov_img]][cov_url]
[![Github action status][gha_img]][gha_url]
[![Dartdocs][doc_img]][doc_url]
[![Style guide][sty_img]][sty_url]

[pub_url]: https://pub.dartlang.org/packages/neouuid
[pub_img]: https://img.shields.io/pub/v/neouuid.svg
[gha_url]: https://github.com/neo-dart/neouuid/actions
[gha_img]: https://github.com/neo-dart/neouuid/workflows/Dart/badge.svg
[cov_url]: https://codecov.io/gh/neo-dart/neouuid
[cov_img]: https://codecov.io/gh/neo-dart/neouuid/branch/main/graph/badge.svg
[doc_url]: https://www.dartdocs.org/documentation/neouuid/latest
[doc_img]: https://img.shields.io/badge/Documentation-neouuid-blue.svg
[sty_url]: https://pub.dev/packages/neodart
[sty_img]: https://img.shields.io/badge/style-neodart-9cf.svg

This library decodes and generates UUIDs, 128-bits represented as 32 hexadecimal digits:

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

## Performance & Compatibility

This package is intended to work identically and well in both the standalone
Dart VM, Flutter, and web builds of Dart and Flutter (both in DDC and Dart2JS).
Contributions are welcome to add special-cased that improves performacne for a
specific platform (as long as there is a fallback for other platforms).

### Benchmarks

| Package     | Equivalent to `Uuid.parse` |
| ----------- | -------------------------- |
| `neouuid`   | 01.55us                    |
| `uuid`      | 15.66us                    |
| `uuid_type` | 00.78us                    |

As of 2022-07-22 on a Macbook Pro (M1), `uuid_type` is ~2x faster:

```bash
dart benchmark/neouuid_parse.dart
dart benchmark/uuid_parse.dart
dart benchmark/uuid_type_parse.dart
```

This is mainly due to this package using `int.parse` instead of building up a
byte buffer from hexadecimel character matches.

## Contributing

Some inspiration:

- <https://github.com/uuidjs/uuid>
- <https://www.uuidtools.com/decode>
