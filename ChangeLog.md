# 0.3.3 (2015.3.27)

- Fix Bug: Causes a crash when some of `@spies_to_reset` gets GCed just before `reinitialize`. [3a1ce2d](https://github.com/igrep/crispy/commit/3a1ce2dfc25ba48d07505b6ed1d7125f393e9579)
- Enhancement: raise error when given some non spied object (or class) by mistake. [4719652](https://github.com/igrep/crispy/commit/4719652d35292749b76fd2531bfec83a4d383a66 )

# 0.3.2 (2015.1.11)

- New Feature: `spied_instances?`. [#28](https://github.com/igrep/crispy/pull/28)
- Enhancement: only for developers of crispy: reduce the number of gems we install by `bundle install`.
- Refactor: minor changes. [`701a051`](https://github.com/igrep/crispy/commit/701a051d3910e8b9f0470c0f3e9cb81ed643f8af)

# 0.3.1 (2015.1.3)

- Enhancement: Forget every spy log and reset every stubbed method by resetting. [#25](https://github.com/igrep/crispy/pull/25)
- Fix bug: Not spied anymore after removing the stubbed methods when resetting. [`cb38ddf`](https://github.com/igrep/crispy/commit/cb38ddf6f0affe2ea884e4a16d7622dca51c1f2d)

# 0.3.0 (2014.12.31)

- New Feature: Add stub feature to `ClassSpy`. [#23](https://github.com/igrep/crispy/pull/23)
- New Feature: Now double is automatically spied without `spy_into`. [#21](https://github.com/igrep/crispy/pull/21)
- Fix Bug: now `spy_into` replaces all stubber's methods with given stub spec when reinitialize a spy. [`0f9157`](https://github.com/igrep/crispy/commit/0f91579decbe27e6b05bec4b779dd1c3ede24380)
- Fix Bug: reset spy log when `spy_into`-ing an already spied object. e.g. Class.[#20](https://github.com/igrep/crispy/pull/20)
- New Feature: `spied?`. [#18](https://github.com/igrep/crispy/pull/18)
- Refactor many internal classes and tests. [#21](https://github.com/igrep/crispy/pull/21) [#22](https://github.com/igrep/crispy/pull/22) [#23](https://github.com/igrep/crispy/pull/23) [#24](https://github.com/igrep/crispy/pull/24)
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
