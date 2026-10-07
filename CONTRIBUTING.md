We're always grateful for contributions of any kind (requests, bug reports, helping people in issues). However before you start working on something, please read this document and follow some simple rules.

## Pull requests & coding conventions

Before you start writing code that might introduce non backwards-compatible changes, like renaming core components of our library, please discuss this with us in an issue here beforehand. Generally if you work on anything besides a bugfix it is a good idea to talk to us first. We hate that you spent hours on something when we have to deny your gwtbootstrap5 request for some reasons or it needs to be changed.

Also if you work on code please follow our coding conventions. We're not going to list every item here. Please look at the existing code to get an idea of our style. We're using the default IntelliJ IDEA code style. Eclipse's default code style for instance is a bad example. Never reformat existing code just because it doesn't suite your style!

1. Indent by **four spaces**
2. Opening brace goes in the same line as the statement (like [1TBS](http://en.wikipedia.org/wiki/Indent_style#Variant:_1TBS))
3. Use `final` keyword wherever applicable
4. Document your code (of course!): the first sentence says what the widget is in Bootstrap's terms, and links to its page of the Bootstrap 5.3 documentation; widgets show a short UiBinder example. The packages listed in `javadoc.documented.packages` of each module's pom are checked in full by CI, so new public API there needs its javadoc: `mvn -P javadoc-check -pl gwtbootstrap5,gwtbootstrap5-extras javadoc:javadoc` runs the same check.

Thank you!

## Updating a bundled JavaScript library

Core and extras bundle the JavaScript and CSS libraries they wrap, and their `XxxURL` modules load the same version from a CDN. [`js-libraries.json`](js-libraries.json) lists each library with its version. To update one:

1. Read its changelog for options the wrapper uses that were renamed or removed. A new major version usually waits for a minor release of GwtBootstrap5.
2. Replace the bundled files (renaming a versioned folder or file), update the URL of its `XxxURL` entry point and the version in `js-libraries.json`.
3. Run `python3 check-js-libraries.py` from the parent: it lists every file, URL or constant that still names another version. CI runs it on every build.
4. For Font Awesome, regenerate the icon enums with `gwtbootstrap5-extras/src/build/fontawesome-enums.py`.
5. Check the library's demo page with `src/test/browser/check.py` in the demo.

Every Monday, `check-js-libraries.py --latest --issues` opens an issue labelled `js-update` in core or extras for each library behind its latest npm release.
