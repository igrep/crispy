# Next version (Unreleased)

- New Feature: Now double is automatically spied without `spy_into`. [#21](https://github.com/igrep/crispy/pull/21)
- Fix Bug: now `spy_into` replaces all stubber's methods with given stub spec when reinitialize a spy.[0f91579decbe27e6b05bec4b779dd1c3ede24380](https://github.com/igrep/crispy/commit/0f91579decbe27e6b05bec4b779dd1c3ede24380)
- Fix Bug: reset spy log when `spy_into`-ing an already spied object. e.g. Class.[#20](https://github.com/igrep/crispy/pull/20)
- New Feature: `spied?`. [#18](https://github.com/igrep/crispy/pull/18)
- Loose required minitest's version.
- Minor document enhancements.

# 0.2.0 (2014.11.1)

- New Feature: `stub_const`. [#11](https://github.com/igrep/crispy/pull/11)
- New Feature: `spy_into_instances`, `spy_of_instances`. [#17](https://github.com/igrep/crispy/pull/17)
- New Feature: `spy().stop`, `spy().restart`. [#17](https://github.com/igrep/crispy/pull/17)
- Compatibility Change: change module structure. [#11](https://github.com/igrep/crispy/pull/11)
    - Now public modules are prefixed with `Crispy` instead of `Crispy::`.
    - Because it seems that we can't refer with `Crispy::World` when including the top level `::Crispy` module.
    - So now we can refer with `CrispyWorld` by including `::Crispy`

# 0.1.2 (2014.8.24)

- Support Ruby 2.0 correctly.

# 0.1.1 (2014.8.23)

- First release.
