# How to contribute

- Reporting bugs
- Suggesting features
- Creating PRs

Welcome all of the contributions!

## Development

At first, you should install development dependencies

```console
$ git clone git@github.com:kachick/eqq.git
$ cd ./eqq
$ bundle install
...
Bundled gems are installed into `./vendor/bundle
```

Using several tools, not limited to the Ruby ecosystem.
An example is [dprint](https://github.com/dprint/dprint).

This project is providing nix flake config for setup around them.
After installing [Nix](https://nixos.org/) package manager, you can do following.

```console
$ nix develop
$ dprint check
$ actionlint
...
```

## Try latest version with REPL

```console
$ ./bin/console
Starting up IRB with loading developing this library
```

## How to make ideal PRs (Not a mandatory rule, feel free to PR!)

If you try to add/change/fix features, please update and/or confirm core feature's tests are not broken.

```console
$ bundle exec rake
$ echo $?
0
```

If you want to run partially tests, test-unit can take some patterns(String/Regexp) with the naming.

```console
$ bundle exec rake test TESTOPTS="-v -n'/test_.*foobar/i'"
Runs test cases only for matched the pattern
```

CI includes signature check, lint, if you want to check them in own machine, below command is the one.

But please don't hesitate to send PRs even if something fail in this command!

```console
$ bundle exec rake simulate_ci
$ echo $?
0
```

## Note

Below commands shows providing rake tasks

```console
$ bundle exec rake --tasks
Summaries will be shown!

$ bundle exec rake -D
Details will be shown!
```
