# Changelog

## Unreleased

### Breaking changes

The APIs deprecated in 0.2.x are removed. [UPGRADING.md](https://github.com/gwtbootstrap5/gwtbootstrap5-parent/blob/master/UPGRADING.md#upgrading-to-030) has the replacement for each one.

- `ListBox(boolean)`: use `new ListBox()` and `setMultipleSelect(true)`.
- `Tooltip` and `Popover`: `reconfigure()`, which did nothing, and `setText(String)`, which only called `setTitle(String)`. **UiBinder templates with `<b:Tooltip text="…">` or `<b:Popover text="…">` stop compiling with GWT** (not with javac): use `title="…"`.
- `ComplexWidget` overrides `insert(Widget, com.google.gwt.dom.client.Element, int, boolean)` instead of GWT's deprecated variant with `com.google.gwt.user.client.Element`. Only subclasses that override that protected method need to change.

## 0.2.0 (2026-10-06)

Bootstrap 5.3.8 for GWT, now on Maven Central as `io.github.gwtbootstrap5`.

**[See every widget running in the demo](https://gwtbootstrap5.github.io/)**, next to the UiBinder code that creates it.

```xml
<dependency>
  <groupId>io.github.gwtbootstrap5</groupId>
  <artifactId>gwtbootstrap5</artifactId>
  <version>0.2.0</version>
</dependency>
<dependency>
  <groupId>io.github.gwtbootstrap5</groupId>
  <artifactId>gwtbootstrap5-extras</artifactId>
  <version>0.2.0</version>
</dependency>
```

### Highlights

- **JsInterop instead of JSNI**, and **no jQuery in the core module**. Popper is loaded by core; the extras that still need jQuery load it themselves.
- **New components:** Offcanvas, Accordion items, Switch, FloatingLabel, Placeholder, InputColor, Ratio, HStack / VStack, VerticalRule, NavUnderline and CardGroup.
- **Color modes:** light and dark for the page or for a single widget, or following the system.
- **More Bootstrap 5.3 options:** dropdowns controlled from Java, fullscreen, centered and scrollable modals, horizontal and flush list groups, check and radio buttons with `btn-check`, validation messages with Bootstrap 5 markup.
- **Many fixes** to markup that was still Bootstrap 3 or 4: breadcrumbs, pagination, dropdown items, navs, popovers, carousel indicators, spinners, alerts, collapse and more. The [demo](https://gwtbootstrap5.github.io/) covers every component.
- **Extras:** Bootbox 6, Tempus Dominus 6 and Air Datepicker 3, Tom Select 2, Summernote 0.9, bootstrap-slider 11, animate.css 4 and Font Awesome 7. `Select` now works without a subclass.

### Upgrading from 0.1.x

The groupId, the jQuery wrapper and several Bootstrap 3/4 widgets and constants changed. [UPGRADING.md](https://github.com/gwtbootstrap5/gwtbootstrap5-parent/blob/master/UPGRADING.md) lists every breaking change with the code to update.

### Links

- [Demo](https://gwtbootstrap5.github.io/) and [getting started](https://gwtbootstrap5.github.io/#setup)
- Javadoc: [core](https://javadoc.io/doc/io.github.gwtbootstrap5/gwtbootstrap5/0.2.0), [extras](https://javadoc.io/doc/io.github.gwtbootstrap5/gwtbootstrap5-extras/0.2.0)
- Maven Central: [core](https://central.sonatype.com/artifact/io.github.gwtbootstrap5/gwtbootstrap5/0.2.0), [extras](https://central.sonatype.com/artifact/io.github.gwtbootstrap5/gwtbootstrap5-extras/0.2.0)
- Issues: [core](https://github.com/gwtbootstrap5/gwtbootstrap5/issues), [extras](https://github.com/gwtbootstrap5/gwtbootstrap5-extras/issues)
