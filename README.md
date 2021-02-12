<!--
 - SPDX-FileCopyrightText: 2018-2019 Serokell <https://serokell.io>
 -
 - SPDX-License-Identifier: MPL-2.0
 -->

# A + B

# A+B

# Xrefcheck

[![Build status](https://badge.buildkite.com/75461331a6058b334383cdfca1071dc1f908b70cf069d857b7.svg?branch=master)](https://buildkite.com/serokell/xrefcheck)

Xrefcheck is a tool for verifying local and external references in repository documentation that is quick, easy to setup, and suitable to be added to CI.

<img src="https://user-images.githubusercontent.com/5394217/70820564-06b06e00-1dea-11ea-9680-27f661ca2a58.png" alt="Output sample" width="600"/>

### Motivation

As the project evolves, links in documentation have a tendency to get broken. This is usually because of:
1. File movements;
2. Markdown header renames;
3. Outer sites ceasing their existence.

This tool will help you to keep references in order.

### Aims

Comparing to alternative solutions, this tool tries to achieve the following points:

* Quickness - local references are verified instantly even for moderately-sized repositories.
* Easy setup - no extra actions required, just run the tool in the repository root.
Both relative and absolute local links are supported out of the box.
* Conservative verifier allows using this tool in CI, no false positives (e.g. on sites which require authentication) should be reported.

### A comparison with other solutions

* [linky](https://github.com/mattias-p/linky) - a well-configurable verifier written in Rust, scans one specified file at a time and works good in pair with system utilities like `find`.
  This tool requires some configuring before it can be applied to a repository or added to CI.
* [awesome_bot](https://github.com/dkhamsing/awesome_bot) - a solution written in Ruby that can be easily included in CI or integrated into GitHub.
  Its features include duplicated URLs detection, specifying allowed HTTP error codes and reporting generation.
  At the moment of writting, it scans only external references and checking anchors is not possible.
* [remark-validate-links](https://github.com/remarkjs/remark-validate-links) and [remark-lint-no-dead-urls](https://github.com/davidtheclark/remark-lint-no-dead-urls) - highly configurable Javascript solution for checking local and remote links resp.
  It is able to check multiple repositores at once if they are gathered in one folder.
  Being written on JavaScript, it is fairly slow on large repositories.
* [markdown-link-check](https://github.com/tcort/markdown-link-check) - another checker written in JavaScript, scans one specific file at a time.
  Supports `mailto:` link resolution.
* [url-checker](https://github.com/paramt/url-checker) - GitHub action which checks links in specified files.
* [linkcheck](https://github.com/filiph/linkcheck) - advanced site crawler, checks for `HTML` files. There are other solutions for this particular task which we don't mention here.


## Usage [↑](#xrefcheck)

We provide the following ways for you to use xrefcheck:

- [GitHub action](https://github.com/marketplace/actions/xrefcheck)
- [statically linked binaries](https://github.com/serokell/xrefcheck/releases)
- [Docker image](https://hub.docker.com/r/serokell/xrefcheck)
- [building from source](#build-instructions-)

If none of those are suitable for you, please open an issue!

To find all broken links in a repository, run from within its folder:

```sh
xrefcheck
```

To also display all found links and anchors:

```sh
xrefcheck -v
```

For description of other options:

```sh
xrefcheck --help
```

## Configuring

Configuration template (with all options explained) can be dumped with:

```sh
xrefcheck dump-config
```

Currently supported options include:
* Timeout for checking external references;
* List of ignored folders.

## Build instructions [↑](#xrefcheck)

Run `stack install` to build everything and install the executable.

### CI and nix [↑](#xrefcheck)

To build only the executables, run `nix-build`. You can use this line on your CI to use xrefcheck:
```
nix run -f https://github.com/serokell/xrefcheck/archive/master.tar.gz -c xrefcheck
```

Our CI uses `nix-build xrefcheck.nix` to build the whole project, including tests and Haddock.
It is based on the [`haskell.nix`](https://input-output-hk.github.io/haskell.nix/) project.
You can do that too if you wish.

## For further work [↑](#xrefcheck)

- [ ] Support for non-Unix systems.
- [ ] Support link detection in different languages, not only Markdown.
  - [ ] Haskell Haddock is first in turn.

## Issue tracker [↑](#xrefcheck)

We use GitHub issues as our issue tracker.
You can login using your GitHub account to leave a comment or create a new issue.

## For Contributors [↑](#xrefcheck)

Please see [CONTRIBUTING.md](/.github/CONTRIBUTING.md) for more information.

## About Serokell [↑](#xrefcheck)

Xrefcheck is maintained and funded with ❤️ by [Serokell](https://serokell.io/).
The names and logo for Serokell are trademark of Serokell OÜ.

We love open source software! See [our other projects](https://serokell.io/community?utm_source=github) or [hire us](https://serokell.io/hire-us?utm_source=github) to design, develop and grow your idea!
