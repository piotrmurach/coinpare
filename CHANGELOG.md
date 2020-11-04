# Change log

## [v0.3.0] - unreleased

### Changed
* Change gemspec to only package lib files
* Update all the tty and thor runtime dependencies
* Remove tty-cursor as a dependency

### Fixed
* Fix Ruby 2.7 keyword conversion errors

## [v0.2.0] - 2019-01-12

### Added
* Add ability to display total purchased and current holdings in pie chart format
* Add vim key navigation bindings for menu selection

### Changed
* Change gemspec to update runtime dependencies, load dependent files directly and require Ruby >= 2.0
* Change to provide error messages for required inputs when creating holdings
* Change coins & markets commands to use system pager and page only when content exceeds screen height

## [v0.1.0] - 2018-05-17

* Initial implementation and release

[v0.3.0]: https://github.com/piotrmurach/coinpare/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/piotrmurach/coinpare/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/coinpare/compare/v0.1.0
