# [0.44.0](https://github.com/hleb-rubanau/appmap-ruby/compare/v0.43.0...v0.44.0) (2021-04-28)


### Features

* **build:** add deployment via `semantic-release` with automatic publication to rubygems ([9f183de](https://github.com/hleb-rubanau/appmap-ruby/commit/9f183de13f405900000c3da979c3a8a5b6e34a24))
* Atomically write AppMap file ([e7381b9](https://github.com/hleb-rubanau/appmap-ruby/commit/e7381b9f104b379455f09d10b6e31030ec484b38))
* Hook before_action and after_action from active support ([42b87dc](https://github.com/hleb-rubanau/appmap-ruby/commit/42b87dc201f24c7726910fe9d01c2f4a6717a040))
* Raise error when appmap.yml doesn't exist ([f564371](https://github.com/hleb-rubanau/appmap-ruby/commit/f564371ee195823f1281213f95572015332205ab))
* Record test_status and exception in the AppMap file ([b6091b8](https://github.com/hleb-rubanau/appmap-ruby/commit/b6091b80435a3ac5c4a30b7a1f8c1f390591704e))
* Refine builtin hooks and add class hooks ([7898336](https://github.com/hleb-rubanau/appmap-ruby/commit/7898336004ca42b5d49ef2d15b4a995d1994fa81))
* Remove outdated exe/appmap ([362b83d](https://github.com/hleb-rubanau/appmap-ruby/commit/362b83dcbffc631a02f7ecf7d76a59c6f7d3b38f))
* Remove source code from appmap ([cc95b5c](https://github.com/hleb-rubanau/appmap-ruby/commit/cc95b5c362e559d8f50fc805e0d30064ad07ba7c))
* Support hooking a specific function, with labels ([9a7fe5a](https://github.com/hleb-rubanau/appmap-ruby/commit/9a7fe5a62353102efb3b54032e3b9c8241da4cc7))
* Support recording and labeling of individual functions ([763af9c](https://github.com/hleb-rubanau/appmap-ruby/commit/763af9cef8431d736b183a1ba13dd2f7f16f5ac9))

# v0.44.0

* Support recording and labeling of indivudal functions via `functions:` section in *appmap.yml*.
* Remove deprecated `exe/appmap`.
* Add `test_status` and `exception` fields to AppMap metadata.
* Write AppMap file atomically, by writing to a temp file first and then moving it into place.
* Remove printing of `Inventory.json` file.
* Remove source code from `classMap`.

# v0.43.0

* Record `name` and `class` of each entry in Hash-like parameters, messages, and return values.
* Record client-sent headers in HTTP server request and response.
* Record HTTP server request `mime_type`.
* Record HTTP server request `authorization`.

# v0.42.1

* Add missing require `set`.
* Check `cls.respond_to?(:singleton_class)`, since it oddly, may not.

# v0.42.0

* Remove `feature_group` and `feature` metadata from minitest and RSpec AppMaps.
* Add `metadata.source_location`.

# v0.41.2

* Don't rely on `gemspec.source_paths` to list all the source locations in a gem. Hook any code that's loaded
  from inside the `gem_dir`.

# v0.41.1

* Make best effort to ensure that class name is not `null` in the appmap.json.
* Don't try and instrument gems which are a dependency of the this gem.
* Fix a nil exception when applying the exclude list to builtins.

# v0.41.0

* Adjust some label names to match `provider.*`, `format.*`.
* Add global `exclude` list to *appmap.yml* which can be used to definitively exclude specific classes and methods.

# v0.40.0

* Parse source code comments into function labels.

# v0.39.2
* Correctly recognize normalized path info for subengines.

# v0.39.1
* Support Ruby 2.7.
* Remove support for Rails 4.
* Stop recommending `-t appmap` argument for `rspec`.

# v0.39.0
* Recognize and record `normalized_path_info` in Rails applications, per 1.4 AppMap format version.

# v0.38.1
* Package configuration can be `shallow`, in case which only the initial entry into the package is recorded.

# v0.37.2
* Fix ParameterFilter deprecation warning.

# v0.37.1
* Fix parameter mapping with keyword and rest arguments.

# v0.37.0
* Capture method source and comment.

# v0.36.0
* *appmap.yml* package definition may specify `gem`.
* Skip loading the railtie if `APPMAP_INITIALIZE` environment variable
  is set to `false`.

# v0.35.2
* Make sure `MethodEvent#display_string` works when the value's `#to_s` and/or `#inspect`
  methods have problems.
  
# v0.35.1
* Take out hooking of `IO` and `Logger` methods.
* Enable logging if either `APPMAP_DEBUG` or `DEBUG` is `true`.

# v0.35.0
* Provide a custom display string for files and HTTP requests.
* Report `mime_type` on HTTP response.

# v0.34.6
* Only warn once about problems determining database version for an ActiveRecord
  connection.

# v0.34.5
* Ensure that hooking a method doesn't change its arity.

# v0.34.4
* Make sure `AppMap:Rails::SQLExaminer::ActiveRecordExaminer.server_version` only calls
  `ActiveRecord::Base.connection.database_version` if it's available.
* Fix `AppMap:Rails::SQLExaminer::ActiveRecordExaminer.database_type` returns `:postgres`
  in all supported versions of Rails.

# v0.34.3
* Fix a crash in `singleton_method_owner_name` that occurred if `__attached__.class` returned
  something other than a `Module` or a `Class`.
  
# v0.34.2
* Add an extension that gets the name of the owner of a singleton method without calling
  any methods that may have been redefined (e.g. `#to_s` or `.name`).
  
# v0.34.1
* Ensure that capturing events doesn't change the behavior of a hooked method that uses
  `Time.now`. For example, if a test expects that `Time.now` will be called a certain
  number of times by a hooked method, that expectation will now be met.
* Make sure `appmap/cucumber` requires `appmap`.

# v0.34.0

* Records builtin security and I/O methods from `OpenSSL`, `Net`, and `IO`.

# v0.33.0

* Added command `AppMap.open` to open an AppMap in the browser.

# v0.32.0

* Removes un-necessary fields from `return` events.

# v0.31.0

* Add the ability to hook methods by default, and optionally add labels to them in the
  classmap. Use it to hook `ActiveSupport::SecurityUtils.secure_compare`.
  
# v0.30.0

* Add support for Minitest.

# v0.29.0

* Add `lib/appmap/record.rb`, which can be `require`d to record the rest of the process.

# v0.28.1

* Fix the `defined_class` recorded in an appmap for an instance method included in a class
  at runtime.
* Only include the `static` attribute on `call` events in an appmap. Determine its value
  based on the receiver of the method call.

# v0.28.0

* Change behavior of **AppMap.record** to return a complete AppMap as a Hash.
* Update README with information about recording Cucumber tests.
* **AppMap.initialize** automatically runs when `AppMap` is required, unless disabled
  by environment variable `APPMAP_INITIALIZE=false`.
* **AppMap.hook** no longer takes a `configuration` argument.
* Add **AppMap::Util.scenario_filename**.

# v0.27.0

* Add **AppMap.record** to programatically record and capture an AppMap of a Ruby block.

# v0.26.1

* Fix a bug that caused duplicate entries in the list of frameworks that appear
  in the `metadata` section of an appmap.
  
# v0.26.0

* **appmap upload** is removed. Upload functionality has been moved to
  the [AppLand CLI](https://github.com/applandinc/appland-cli).

# v0.25.2

* Stop checking a whitelist to see if each SQL query should be recorded. Record
all queries.

# v0.25.1

* Ensure that caught exceptions are re-raised.
* Add safety around indexing potentially nil backtrace locations. 

# v0.25.0

* Reports `exceptions` in [function return attributes](https://github.com/applandinc/appmap#function-return-attributes).

# v0.24.1
* Fixes an issue which prevented a remote recording from returning scenario data successfully.
* Remote recording routes now return descriptive status codes as intended.
* Remote recording routes now have the correct `Content-Type` header.

# v0.24.0

Internals of `appmap-ruby` have been changed to record each method event using `alias_method`,
rather than `TracePoint`. Performance is much better as a result.

**WARNING** Breaking changes

* **Rack** apps no longer generate `http_server_request` events.
* **appmap inspect** has been removed. `appmap-ruby` no longer parses the source tree. Instead, it observes the methods as they are loaded by the VM. So, to get a class map, you have to create a recording. The `RSpec` recorder still prints an inventory to `Inventory.appmap.json` when it exits. The class map in this file contains every class and method which was loaded by any of the tests.

# v0.23.0

* **appmap stats** command added.

# v0.22.0

* **RSpec** recorder generates an "inventory" (AppMap with classMap, without events) named `Inventory.appmap.json`.
* **appmap inspect** generates an inventory AppMap which includes `version`, `metadata`, and `classMap`. Previously, the file output by this command was the class map represented as an array.

# v0.21.0

* Scenario data includes `recorder` and `client` info, describing how the data was recorded.

# v0.20.0

Updated to [AppMap file format](https://github.com/applandinc/appmap) version 1.2.

* **Event `message`** is now an array of parameter objects.
* The value of each `appmap:` tags in an RSpec is recorded as a `label` in the AppMap file metadata.
* `layout` is removed from AppMap file metadata.

# v0.19.0

* **RSpec** feature and feature group names can be inferred from example group and example names.
* Stop using `ActiveSupport::Inflector.transliterate`, since it can cause exceptions.
* Handle StandardError which occurs while calling `#inspect` of an object.

# v0.18.1

* Now tested with Rails 4, 5, and 6.
* Now tested with Ruby 2.5 and 2.6.
* `explain_sql` is no longer collected.
* `appmap/railtie` is automatically required when running in a Rails environment.

# v0.17.0

**WARNING** Breaking changes

* **appmap upload** expects arguments `user` and `org`.
* **appmap upload** receives and retransmits the scenario batch id
* assigned by the server.

# v0.16.0

**WARNING** Breaking changes

* **Record button** removed. Frontend interactions are now recorded with a browser extension.
  As a result, `AppMap::Middleware::RecordButton` has been renamed to 
  `AppMap::Middleware::RemoteRecording`

# v0.15.1

* **Record button** moved to the bottom of the window.

# v0.15.0

**WARNING** Breaking changes

* **AppMap version** updated to 1.1
* **Event `parameters`** are reported as an array rather than a map, so that parameter order is preserved.
* **Event `receiver`** reports the `receiver/this/self` parameter of each method call.

# v0.14.1

* **RSpec recorder** won't try to modify a frozen string.

# v0.14.0

* **SQL queries** are reported for SQLite.

# v0.13.0

* **SQL queries** are reported for ActiveRecord.

# v0.12.0

* **Record button** integrates into any HTML UI and provides a button to record and upload AppMaps.

# v0.11.0

* Information about `language` and `frameworks` is provided in the AppMap `metadata`.

# v0.10.0

* **`AppMap::Algorithm::PruneClassMap`** prunes a class map so that only functions, classes and packages which are
  referenced by some event are retained.

# v0.9.0

* **`appmap/rspec`** only records trace events which happen during an example block. `before` and `after` events are
  excluded from the AppMap.
* **`appmap/rspec`** exports `feature` and `feature_group` attributes to the AppMap `metadata`
  section.

# v0.8.0

* **`appmap upload`** accepts multiple arguments, to upload multiple files in one command.

# v0.7.0

* **`appmap/railtie`** is provided to integrate AppMap recording into Rails apps.
  * Use `gem :appmap, require: %w[appmap appmap/railtie]` to activate.
  * Set Rails configuration setting `config.appmap.enabled = true` to enable recording of the app via the Railtie, and
    to enable recording of RSpec tests via `appmap/rspec`.
  * In a non-Rails environment, set `APPMAP=true` to to enable recording of RSpec tests.
* **SQL queries** are reported as AppMap event `sql_query` data.
* **`self` attribute** is removed from `call` events.

# v0.6.0

* **Web server requests and responses** through WEBrick are reported as AppMap event `http_server_request` data.
* **Rails `params` hash** is reported as an AppMap event `message` data.
* **Rails `request`** is reported as an AppMap event `http_server_request` data.

# v0.5.1

* **RSpec** test recorder is added.

# v0.5.0

* **'inspect', 'record' and 'upload' commands** are converted into a unified 'appmap' command with subcommands.
* **Config file name** is changed from .appmap.yml to appmap.yml.
* **`appmap.yml`** configuration format is updated.

# v0.4.0

Initial release.
