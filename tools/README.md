# Quails dev tools

This is a collection of utilities used for Quails internal development.
They aren't used by Quails apps directly.

  * `console` drops you in irb and loads local Quails repos
  * `profile` profiles `Kernel#require` to help reduce startup time
  * `line_statistics` provides CodeTools module and LineStatistics class to count lines
  * `test` is loaded by every major component of Quails to simplify testing, for example:
    `cd ./actioncable; bin/test ./path/to/actioncable_test_with_line_number.rb:5`
