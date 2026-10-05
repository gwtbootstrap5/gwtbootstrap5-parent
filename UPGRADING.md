# Upgrading to 0.2.0

GWTBootstrap5 0.2.0 replaces all JSNI (`/*-{ }-*/` methods) and `JavaScriptObject` overlay types with JsInterop, in both `gwtbootstrap5` and `gwtbootstrap5-extras`. Core widgets now call Bootstrap 5's own JavaScript API instead of jQuery.

This is a clean break: the old signatures are removed, not deprecated. Most applications only use the widgets and won't need to change any code. You need to change code if you use any of the following:

| You use | Section |
| --- | --- |
| jQuery in your own code, relying on GWTBootstrap5 to load it | [jQuery is no longer loaded by core](#jquery-is-no-longer-loaded-by-core) |
| `org.gwtbootstrap5.client.shared.js.JQuery` or `EventHandler` | [Core jQuery wrapper removed](#core-jquery-wrapper-removed) |
| `GwtBootstrap5ClientBundle.gwtBootstrap5()`, `jQuery()` or `jQueryMigrate()` | [Client bundle resources removed](#client-bundle-resources-removed) |
| `Affix` | [Affix uses sticky positioning](#affix-uses-sticky-positioning) |
| `Styles.FORM_CONTROL_RANGE` / `FORM_CONTROL_FILE`, or `InputRange` / `InputFile` with custom CSS | [InputRange and InputFile use Bootstrap 5 classes](#inputrange-and-inputfile-use-bootstrap-5-classes) |
| `NavbarPosition.STATIC_TOP`, `ProgressType`, `Progress.setType` / `setActive`, `TableType.INVERSE`, `THeadType`, `ColumnOffset.XS_0` / `XS_12`, `ButtonType.LINK_OUTLINE`, or the `Styles` / `Spy` / `Toggle` constants listed there | [Bootstrap 3/4 constants removed](#bootstrap-34-constants-removed) |
| Buttons without an explicit type, or `ButtonType.DEFAULT` | [Buttons default to btn-light](#buttons-default-to-btn-light) |
| `Label` / `LabelType`, or `Styles.LABEL` | [Label is replaced by Badge](#label-is-replaced-by-badge) |
| `NavbarType` | [Navbar theme uses data-bs-theme](#navbar-theme-uses-data-bs-theme) |
| `FormType`, `Form(FormType)`, `ButtonGroup.setToggle`, `setDataLoadingText`, `Caption`, `ThumbnailLink` | [Removed widgets and methods](#removed-widgets-and-methods) |
| `Animation.LIGHTSPEED_IN`, `LIGHTSPEED_OUT` or `SHAKE` | [Animate uses animate.css 4 names](#animate-uses-animatecss-4-names) |
| `ColumnPull` / `ColumnPush`, `Column.setPull` / `setPush` | [Column order replaces pull and push](#column-order-replaces-pull-and-push) |
| `DropDownMenu.setFloat`, or `float` on a `DropDownMenu` in UiBinder | [Dropdown menus align with setAlignment](#dropdown-menus-align-with-setalignment) |
| `ListGroupItem.setFlush` | [List group flush and horizontal](#list-group-flush-and-horizontal) |
| `CheckBoxButton` / `RadioButton` with your own CSS or click handlers | [Check and radio buttons use btn-check](#check-and-radio-buttons-use-btn-check) |
| CSS of your own for `Radio`, `InlineRadio` or `InlineCheckBox` | [Checkboxes and radios use form-check markup](#checkboxes-and-radios-use-form-check-markup) |
| The extras `org.gwtbootstrap5.extras.popper` module | [Popper is loaded by core](#popper-is-loaded-by-core) |
| Bootbox `DialogOptions`, `AlertOptions`, `ConfirmOptions` or `PromptOptions` as a `JavaScriptObject` | [Bootbox](#bootbox) |
| `TempusDominusLocales` or `AirDatepickerLocales` | [Datetimepicker locales](#datetimepicker-locales) |
| `Range.toJsArray()`, `new Range(JsArrayNumber)`, or a subclass of `RangeBase` | [Range / slider](#range--slider) |
| `SummernoteImageUploadEvent.ImageFile`, `getImages()` or `insertImages()` | [Summernote](#summernote) |

## Update the dependency

```xml
<dependency>
  <groupId>org.gwtbootstrap5</groupId>
  <artifactId>gwtbootstrap5</artifactId>
  <version>0.2.0</version>
</dependency>
<dependency>
  <groupId>org.gwtbootstrap5</groupId>
  <artifactId>gwtbootstrap5-extras</artifactId>
  <version>0.2.0</version>
</dependency>
```

Both modules now depend on `elemental2-dom` (which brings in `elemental2-core` and `jsinterop-base`). Maven pulls them in for you, and the GWT modules inherit `elemental2.dom.Dom` and `jsinterop.base.Base`, so your `.gwt.xml` doesn't need to change.

## Host page and script loading

### jQuery is no longer loaded by core

`gwtbootstrap5` no longer loads jQuery or jQuery Migrate. Only the extras whose third-party library still needs jQuery load it, and only when jQuery isn't already on the page:

| Module | Loads jQuery |
| --- | --- |
| Core `gwtbootstrap5` | No |
| Bootbox, Summernote, ColorPicker, jQuery UI | Yes (bundled, or from the jQuery CDN in the `*URL` modules) |
| Range (bootstrap-slider) | No. It uses bootstrap-slider's vanilla API |
| Everything else in extras | No |

**If your own code uses jQuery** (`$`, `jQuery`, or jQuery plugins you add yourself), load it in your host page before the GWT module:

```html
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="mymodule/mymodule.nocache.js"></script>
```

Bootstrap only registers its jQuery plugins (`$.fn.modal`, `$.fn.tooltip`, ...) if jQuery is already present when Bootstrap loads. When an extra loads jQuery after core has loaded Bootstrap, it registers those plugins itself, so jQuery-based libraries such as Bootbox keep working. You don't need to do anything for this.

### Bootstrap detection

Core checks for `window.bootstrap` to decide whether to inject Bootstrap's JavaScript. If your host page already loads Bootstrap 5, core won't inject it again.

### Popper is loaded by core

Bootstrap 5's dropdowns, popovers and tooltips need Popper, and so does Tempus Dominus. In 0.1.x, `GwtBootstrap5` didn't load Popper, so tooltips failed with `Bootstrap's tooltips require Popper` unless you also inherited the extras `popper` module.

Core now includes Popper 2.11.8. `GwtBootstrap5` injects it (and `GwtBootstrap5URL` loads it from jsDelivr) before Bootstrap, whenever the `window.Popper` global is missing. This happens even if your host page already loads Bootstrap, because `bootstrap.bundle.js` embeds Popper without exposing that global, and Tempus Dominus needs it.

The extras `popper` module is removed. Remove these inherits from your `.gwt.xml`:

```xml
<inherits name="org.gwtbootstrap5.extras.popper.Popper"/>
<inherits name="org.gwtbootstrap5.extras.popper.PopperURL"/>
<inherits name="org.gwtbootstrap5.extras.popper.PopperNoResources"/>
```

If you use `GwtBootstrap5NoResources`, your host page loads Bootstrap itself and must also provide the `window.Popper` global (load `popper.min.js`) if you use Tempus Dominus.

## Core (`gwtbootstrap5`)

### Core jQuery wrapper removed

`org.gwtbootstrap5.client.shared.js.JQuery` and `org.gwtbootstrap5.client.shared.js.EventHandler` are removed. Use the widget's own API where it has one. Otherwise, use the native Bootstrap types in the same package (`BootstrapModal`, `BootstrapToast`, `BootstrapCarousel`, `BootstrapCollapse`, `BootstrapTab`, `BootstrapTooltip`, `BootstrapPopover`, `BootstrapAlert`, `BootstrapScrollSpy`) and plain DOM events.

Before:

```java
JQuery.jQuery(element).modal("show");
JQuery.jQuery(element).on("shown.bs.modal", event -> onShown());
```

After:

```java
BootstrapModal.getOrCreateInstance(element, null).show();

// Bootstrap 5 events are native DOM events
DomEventListeners listeners = new DomEventListeners();
listeners.add(element, "shown.bs.modal", event -> onShown());
// ... and when the widget is detached:
listeners.removeAll();
```

If you only need jQuery itself, load it in your host page (see above). The extras module has its own `org.gwtbootstrap5.extras.shared.js.JQuery` type, but it only covers the plugins the extras need (Summernote, bootstrap-colorpicker) and isn't meant as a general jQuery API.

### Client bundle resources removed

`GwtBootstrap5ClientBundle.gwtBootstrap5()`, `jQuery()` and `jQueryMigrate()` are removed, and so are the files behind them (`gwtbootstrap5.js` and the bundled jQuery / jQuery Migrate). `GwtBootstrap5ClientBundle.bootstrap()` is still there.

If you injected jQuery from the core bundle, load it in your host page instead, or call `org.gwtbootstrap5.extras.shared.js.JQueryLoader.ensureLoaded()` if you depend on `gwtbootstrap5-extras`.

### Affix uses sticky positioning

Bootstrap 5 removed the affix plugin, so `Affix` didn't work on 0.1.x: it called `$.fn.affix`, which no longer exists. It now uses CSS sticky positioning (Bootstrap's `sticky-top` class):

- The offset is the distance in pixels **from the top of the viewport** at which the element sticks. In Bootstrap 3's affix it was the number of pixels scrolled before the element was pinned.
- A sticky element sticks within its parent, so the parent must be taller than the element.

### InputRange and InputFile use Bootstrap 5 classes

`InputRange` used the Bootstrap 4 classes `form-control form-control-range`, so it rendered as an unstyled slider inside a text-field border. It now has only Bootstrap 5's `form-range` class.

`Styles.FORM_CONTROL_RANGE` (`"form-control-range"`) is replaced by `Styles.FORM_RANGE` (`"form-range"`). If you styled `.form-control-range` yourself, target `.form-range` instead.

`InputFile` also loses the Bootstrap 4 class `form-control-file`, which Bootstrap 5 doesn't style; it keeps `form-control`, which is all Bootstrap 5 needs. `Styles.FORM_CONTROL_FILE` is removed. If you styled `.form-control-file` yourself, target `.form-control[type=file]` instead.

### New: InputColor

`InputColor` is Bootstrap 5's native color picker (`<input type="color" class="form-control form-control-color">`). Its value is a lowercase hex color such as `#563d7c`, and it fires `ValueChangeEvent` like any input. It needs no jQuery; use the extras `ColorPicker` when you need its inline panel or an alpha channel.

### Bootstrap 3/4 constants removed

These constants wrote Bootstrap 3 or 4 classes that don't exist in Bootstrap 5, so they had no effect:

| Removed | Use instead |
| --- | --- |
| `NavbarPosition.STATIC_TOP` | `NavbarPosition.STICKY_TOP` (`sticky-top`); `STICKY_BOTTOM` is new |
| `ProgressType`, `Progress.setType(...)` | `ProgressBar.setStriped(true)` on each bar |
| `Progress.setActive(...)` | `ProgressBar.setAnimated(true)` on each bar |
| `TableType.INVERSE` | `TableType.DARK`; `CellTable.setInverse` / `DataGrid.setInverse` now add `table-dark` |
| `THeadType` | `table-light` / `table-dark` on the header row, with `addStyleName` |
| `ColumnOffset.XS_0`, `ColumnOffset.XS_12` | Nothing: Bootstrap 5 has no `offset-0` or `offset-12` |
| `ButtonType.LINK_OUTLINE` | `ButtonType.LINK` |
| `Styles.IN`, `HIDE`, `WIDTH`, `RADIO`, `CAROUSEL_CONTROL` | `Styles.SHOW` for `in`; `d-none` for `hide`; `Styles.COLLAPSE_HORIZONTAL` for `width`; the others have no replacement |
| `Spy.AFFIX`, `Toggle.BUTTONS` | Nothing: Bootstrap 5 removed affix and the buttons plugin |

`NavbarPosition.FIXED_TOP` / `FIXED_BOTTOM` now write `fixed-top` / `fixed-bottom` and fix the navbar, and `RowContentJustifyAlign` writes `justify-content-*` (it wrote `align-items-*`, so it aligned vertically); `EVENLY` is new.

### Buttons default to btn-light

`ButtonType.DEFAULT` wrote Bootstrap 3's `btn-default`, which doesn't exist in Bootstrap 5, so every button created without a type had no color. It's removed, and `Button`, `AnchorButton`, `SubmitButton`, `CheckBoxButton`, `RadioButton`, the toggle buttons and `ButtonCell` now default to `ButtonType.LIGHT` (`btn-light`), the closest to Bootstrap 3's white default button.

Before:

```java
button.setType(ButtonType.DEFAULT);
```

After:

```java
button.setType(ButtonType.LIGHT); // or SECONDARY, SECONDARY_OUTLINE, ...
```

### Label is replaced by Badge

Bootstrap 4 removed labels. `Label` rendered a `badge` whose `label-*` colors don't exist, so it had no color. `Label` and `LabelType` are removed; use `Badge` and `BadgeType`. `Styles.LABEL` is renamed `Styles.BADGE`.

| 0.1.x | 0.2.0 |
| --- | --- |
| `new Label(LabelType.SUCCESS, "Saved")` | `Badge badge = new Badge("Saved"); badge.setType(BadgeType.SUCCESS);` |
| `LabelType.DEFAULT` | `BadgeType.SECONDARY` |
| `LabelType.PRIMARY`, `SUCCESS`, `INFO`, `WARNING`, `DANGER` | The `BadgeType` constant with the same name |

In UiBinder, replace `<b:Label type="SUCCESS" text="Saved"/>` with `<b:Badge type="SUCCESS" text="Saved"/>`.

### Navbar theme uses data-bs-theme

Bootstrap 5.3 deprecated `navbar-light` / `navbar-dark` in favor of the `data-bs-theme` attribute, and `navbar-light` no longer has any CSS. `NavbarType.DEFAULT` / `INVERSE` are replaced by `LIGHT` / `DARK`, which set `data-bs-theme="light"` / `"dark"` on the navbar (its dropdowns follow). A new `Navbar` no longer gets a type, so it inherits the page's theme; `getType()` returns `null` until you set one, and `setType(null)` removes the attribute.

Before:

```java
navbar.setType(NavbarType.INVERSE);
```

After:

```java
navbar.setType(NavbarType.DARK);
```

Combine it with a background utility class (`bg-dark`, `bg-body-tertiary`) as in Bootstrap's examples.

### Removed widgets and methods

| Removed | Why | Use instead |
| --- | --- | --- |
| `FormType`, `Form(FormType)`, `Form.setType` / `getType`, `FormPanel.setType` / `getType` | `form-inline` was removed in Bootstrap 5 | An inline form is a `Row` with `Column`s (`row g-3 align-items-center`) |
| `ButtonGroup.setToggle`, `Styles.BTN_GROUP_TOGGLE` | `btn-group-toggle` and the buttons plugin were removed in Bootstrap 5 | Nothing: `CheckBoxButton` / `RadioButton` work in any `ButtonGroup` |
| `AbstractButton.setDataLoadingText`, `Attributes.DATA_LOADING_TEXT` | The button loading state was Bootstrap 3 | Change the text and `setEnabled(false)` yourself, optionally with a `Spinner` |
| `Caption`, `ThumbnailLink`, `Styles.CAPTION` | Thumbnails were removed in Bootstrap 4 | `Card`, or `Image` with `ImageType.THUMBNAIL` inside an `Anchor` |

### Column order replaces pull and push

Bootstrap 4 replaced the pull / push classes with flexbox order. `ColumnPull` and `ColumnPush` wrote `order-1` / `order-2` whatever the number you chose, so `XS_3` and `XS_8` did the same thing. They're removed, with `Column.setPull`, `addPull`, `setPush` and `addPush`. The new `ColumnOrder` has every `order-*` class of Bootstrap 5: `0` to `5`, `FIRST` and `LAST`, for `XS` to `XXL`.

Before:

```java
column.setPush(ColumnPush.MD_6);
```

After:

```java
column.setOrder(ColumnOrder.MD_LAST);   // or MD_0 ... MD_5, MD_FIRST
```

In UiBinder: `<b:Column size="XS_6" order="XS_FIRST MD_LAST"/>`.

### Check and radio buttons use btn-check

`CheckBoxButton` and `RadioButton` relied on Bootstrap 3/4's jQuery buttons plugin to hide the input and mark the button `active`. In 0.1.x they showed a checkbox or radio inside the button and never looked pressed. They now follow Bootstrap 5's check buttons:

- The input has `btn-check`, so Bootstrap hides it, and the button gets `active` (Bootstrap's pressed style) while the input is checked. For radios, the whole group (inputs with the same `name`) is kept in sync, including the button that gets unchecked.
- `ValueChangeEvent` fires once per change, from the input's `change` event. It used to fire from click handlers, which saw the old value on the label's click.
- `setValue(...)` and `setActive(...)` update the `active` class too.
- The keyboard focus ring is drawn on the button while the hidden input has keyboard focus.

The root element is still the `label.btn` with the input as its first child, so they keep working inside `ButtonGroup`. If you styled the visible input or relied on the order of click events, review that code.

### Modal can be centered and scrollable

New: `Modal.setCentered(true)` centers the dialog vertically (`modal-dialog-centered`), and `Modal.setScrollable(true)` scrolls the body instead of the page (`modal-dialog-scrollable`). Both work as UiBinder attributes: `<b:Modal centered="true" scrollable="true">`.

### Dropdown menus align with setAlignment

`DropDownMenu.setFloat` now throws `UnsupportedOperationException`. In Bootstrap 5, Popper positions the menu, so `float-end` never moved it. Use `setAlignment` instead. To change the alignment from a breakpoint up, add `setBreakpointAlignment`:

```xml
<b:DropDownMenu alignment="END">                                 <!-- was float="RIGHT_XS" -->
<b:DropDownMenu alignment="END" breakpointAlignment="LG_START">  <!-- end, start from lg up -->
```

### Dropdowns can be controlled from Java

New: `DropDown`, `ListDropDown` and `NavbarDropdown` implement `HasDropDown`:

- `show()`, `hide()` and `toggle()`, through the new native type `BootstrapDropdown`.
- `ShowEvent`, `ShownEvent`, `HideEvent` and `HiddenEvent`, the same events `Collapse` uses.
- `setDirection(DropDownDirection)`: `DOWN`, `DOWN_CENTER`, `UP`, `UP_CENTER`, `START` or `END`.
- `setAutoClose(DropDownAutoClose)`: `TRUE`, `FALSE`, `INSIDE` or `OUTSIDE`, written as `data-bs-auto-close` on the toggle.

The toggle must be a direct child with `data-bs-toggle="dropdown"`, as in the existing UiBinder examples.

### Accordion items

New: `AccordionItem`, `AccordionHeader` and `AccordionBody` build the accordion markup. When an item is attached, it links the header's button to the body with a generated id (`data-bs-target`, `aria-controls`, `aria-expanded`), so you no longer assemble `Collapse` and ids by hand:

```xml
<b:Accordion flush="true">
    <b:AccordionItem open="true">
        <b:AccordionHeader text="First"/>
        <b:AccordionBody>...</b:AccordionBody>
    </b:AccordionItem>
</b:Accordion>
```

- **One item open at a time:** this is the default; each body gets `data-bs-parent` pointing to the accordion. `Accordion.setAlwaysOpen(true)` lets several stay open.
- **Opening and closing:** `AccordionItem.setOpen` sets the initial state. Once the item is attached, it animates like a click, and `isOpen()` reads the current state.
- **Flush:** `Accordion.setFlush(true)` adds `accordion-flush`.
- **Header content:** `AccordionHeader` takes `text` or child widgets; both go inside the button.

### List group flush and horizontal

`ListGroupItem.setFlush` is removed: it put `list-group-flush` on the item, where Bootstrap ignores it. Use `ListGroup.setFlush(true)` on the group instead.

New: `ListGroup.setHorizontal(ListGroupHorizontal)` lays the items out in a row, `ALWAYS` or from a breakpoint up (`SM` to `XXL`).

### More Bootstrap 5.3 options

New:

- **Fullscreen modal:** `Modal.setFullscreen(ModalFullscreen)` covers the viewport, `ALWAYS` or below a breakpoint (`SM_DOWN` to `XXL_DOWN`). It combines with `setSize`.
- **Underline nav:** `NavUnderline`, a nav whose active link is underlined (`nav-underline`), alongside `NavTabs` and `NavPills`.
- **`setFill` on every nav:** it moves from `NavPills` to `Nav`, so `NavTabs` and `NavUnderline` have it too. `NavPills` code keeps working.
- **Card groups:** `CardGroup` joins `Card`s in a row of equal height (`card-group`).

`Nav.setVertical(false)` now removes `flex-column`. It used to remove `nav-justified` instead, so the nav stayed vertical and lost justification.

### Checkboxes and radios use form-check markup

`Radio`, `InlineRadio` and `InlineCheckBox` now render the same Bootstrap 5 markup as `CheckBox`, and every label is linked to its input with `for`, so clicking the text toggles the input:

```html
<div class="form-check">                      <!-- InlineRadio / InlineCheckBox: form-check form-check-inline -->
  <input type="radio" class="form-check-input" id="gwt-uid-2">
  <label class="form-check-label" for="gwt-uid-2">Label</label>
</div>
```

`Radio` used Bootstrap 3's `div.radio > label > input`, and the inline widgets used a `label.form-check` wrapper without `form-check-inline` or the input / label classes. If you styled `.radio` or those wrappers yourself, target `.form-check` instead.

## Extras (`gwtbootstrap5-extras`)

### Bootbox

The options classes are no longer `JavaScriptObject`s. `newOptions()` and every setter are unchanged, so code that only uses them compiles as before. Only code that called `JavaScriptObject` methods breaks.

Before:

```java
DialogOptions options = JavaScriptObject.createObject().cast();
AlertOptions alert = someJavaScriptObject.cast();
```

After:

```java
DialogOptions options = DialogOptions.newOptions("Message");
AlertOptions alert = AlertOptions.newOptions("Message");
```

The callback interfaces (`SimpleCallback`, `ConfirmCallback`, `PromptCallback`) are unchanged.

Bootbox 6 requires a title for prompts. `PromptOptions.newOptions(message)` sets only the message, so also call `setTitle(...)`, or Bootbox throws `prompt requires a title`.

### Datetimepicker locales

The locale lookups return `Object` instead of `JavaScriptObject`:

- `TempusDominusLocales.getLocaleAndLoadItIfNotLoaded(String)`
- `TempusDominusLocales.getLocale(String)`
- `AirDatepickerLocales.getLocaleAndLoadItIfNotLoaded(String)`

Before:

```java
JavaScriptObject locale = TempusDominusLocales.getLocaleAndLoadItIfNotLoaded("de");
```

After:

```java
Object locale = TempusDominusLocales.getLocaleAndLoadItIfNotLoaded("de");
```

The built-in English Tempus Dominus locale (`"en"`) now returns `null` instead of throwing a `NullPointerException`, and a `null` locale isn't loaded.

### Range / slider

`Range` uses elemental2 arrays instead of `JsArrayNumber`:

Before:

```java
JsArrayNumber array = range.toJsArray();
Range range = new Range(jsArrayNumber);
```

After:

```java
elemental2.core.JsArray<Double> array = range.toJsArray();
Range range = new Range(jsArrayOfDoubles);
```

`Range.fromString(String)` and `new Range(double, double)` are unchanged.

**Subclasses of `RangeBase`** (most applications only use `Slider` and `RangeSlider`, and can skip this): the protected hooks that took `Element`, `Event` or `JavaScriptObject` are replaced by two conversion methods. Remove `setValue(Element, T)`, `getValue(Element)`, `setFormatterOption(JavaScriptObject)`, `setFormatter(Element)`, `onSlide(Event)`, `onSlideStart(Event)`, `onSlideStop(Event)` and `onSlideChange(Event)`, and implement:

```java
/** Converts a value to the number (or two-number array) bootstrap-slider expects. */
protected abstract Object toJsValue(T value);

/** Converts a number (or two-number array) from bootstrap-slider; may receive null. */
protected abstract T toValue(Object value);
```

`isSliderNamespaceAvailable()` is removed: Range no longer uses jQuery, so there is no `slider` / `bootstrapSlider` namespace to check.

Behavior changes:

- Options set before the slider is attached are now applied. In 0.1.x they were written to `data-bs-slider-*` attributes, which bootstrap-slider ignores. If you set those attributes yourself (for example in UiBinder), rename them to `data-slider-*`.
- Changing an option on an attached slider (`setStep`, `setTicks`, `setFormatter`, ...) recreates the slider and keeps its current value. In 0.1.x the value was reset, and adding ticks after creation broke the layout. `refresh()` still calls bootstrap-slider's `refresh()`.
- `getOrientation()`, `getTooltip()`, `getSelection()`, `getHandle()`, `getScale()` and `getTooltipPosition()` return the actual setting. They used to always return the default.

### Animate uses animate.css 4 names

The bundled animate.css 4 renamed three animations, so `Animation.LIGHTSPEED_IN`, `LIGHTSPEED_OUT` and `SHAKE` did nothing. They're replaced by the version 4 names:

| 0.1.x | 0.2.0 |
| --- | --- |
| `Animation.LIGHTSPEED_IN` | `Animation.LIGHTSPEED_IN_RIGHT` or `LIGHTSPEED_IN_LEFT` |
| `Animation.LIGHTSPEED_OUT` | `Animation.LIGHTSPEED_OUT_RIGHT` or `LIGHTSPEED_OUT_LEFT` |
| `Animation.SHAKE` | `Animation.SHAKE_X` or `SHAKE_Y` |

### Summernote

`SummernoteImageUploadEvent.ImageFile` is removed. Uploaded images are `elemental2.dom.File` objects:

| Method | 0.1.x | 0.2.0 |
| --- | --- | --- |
| `SummernoteImageUploadEvent.getImages()` | `com.google.gwt.core.client.JsArray<ImageFile>` | `elemental2.core.JsArray<File>` |
| `SummernoteBase.insertImages(...)` | `com.google.gwt.core.client.JsArray<ImageFile>` | `elemental2.core.JsArray<File>` |

Before:

```java
summernote.addSummernoteImageUploadHandler(event -> {
    JsArray<ImageFile> images = event.getImages();
    for (int i = 0; i < images.length(); i++) {
        ImageFile image = images.get(i);
        upload(image.getName(), image.getSize(), image.getType());
    }
});
```

After:

```java
summernote.addSummernoteImageUploadHandler(event -> {
    JsArray<File> images = event.getImages();
    for (int i = 0; i < images.length; i++) {
        File image = images.getAt(i);
        upload(image.name, image.size, image.type);
    }
});
```

`ImageFile.getMetadata()` has no replacement. Build the string from `name`, `size` and `type` if you need it.

`insertImages(...)` now inserts the images as data URLs. In 0.1.x it called a command that doesn't exist in Summernote 0.9, so it never inserted anything.

## Other fixes that change behavior

- Summernote is 0.9.1 (it was 0.9.0 bundled and 0.9.1 from the CDN) and loads only its Bootstrap 5 build: the Bootstrap 3 build and its CSS were loaded too, and overridden.
- `IconTypeFABrands.BRAND_11TY`, `BRAND_42_GROUP` and `BRAND_500PX` show their icons: they wrote `fa-brand-11ty` and so on instead of `fa-11ty`, `fa-42-group` and `fa-500px`.

- `Spinner` is visible: `SpinnerType.BORDER` / `GROW` wrote `label-default` / `label-primary` instead of `spinner-border` / `spinner-grow`.
- `Alert.setFade(true)` keeps the alert visible: it added `fade in`, and in Bootstrap 5 `fade` without `show` has opacity 0.
- `Collapse` and `NavbarCollapse` start open when they should, and `isShown()` / `setIn()` work: they used Bootstrap 3's `in` instead of `show`.

- `Toast.isShown()` returns whether the toast is shown. It used to return the jQuery object.
- `Modal.setHideOtherModals(true)` works again: opening the modal hides the other open modals. It used the Bootstrap 3 `.modal.in` selector, which never matched in Bootstrap 5.
- `DateTimePicker`, `DatePicker` and `TimePicker` with the Tempus Dominus engine work. In 0.1.x they threw `b.display is undefined` when attached, and reading the value failed because `picked` is a getter. Each picker now gets its own localization, so an English picker created after a German one stays in English, and `setLocale(...)` after attach switches the language. English month names are in English rather than the browser's language.
- With the Air Datepicker engine, `hide()` on a picker that is already hidden (for example after it closed itself on selection) no longer throws, `setMinDate` / `setMaxDate` pass real JS dates instead of relying on the browser parsing GWT's `Date.toString()`, and unset hour / minute steps keep Air Datepicker's default of 1 instead of 0.
- The native `TempusDominus` type's `setLocale(String)`, which doesn't exist in Tempus Dominus 6, is replaced by `locale(String)`.
- `RangeBase.isVisible()` no longer recurses forever when the slider isn't attached.
- A `RangeSlider` with a formatter no longer throws a `NullPointerException`. bootstrap-slider also passes single numbers, for the separate min / max tooltips, and those become a `Range` with equal bounds.

## Known issues

- `Bootbox.init(SimpleCallback)` never calls its callback. In Bootbox 6, `bootbox.init(...)` reinitialises Bootbox instead of registering a callback. This was already the case in 0.1.x.
