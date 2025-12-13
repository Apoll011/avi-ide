# Avi Studio

Avi Studio is a lightweight IDE for creating, editing, and testing **Avi skills**.

![screenshot](https://pragtical.github.io/assets/img/editor.png)

It is built specifically for the Avi ecosystem and focuses on the Avi DSL and skill workflow, rather than being a general-purpose editor.

Avi Studio is a fork of **Pragtical**, which itself is a fork of **Lite XL**. It keeps the same core philosophy: fast startup, small footprint, C core with Lua extensibility.

> ⚠️ **Early development**: this project is experimental and incomplete.

---
## Download

* **[Get Avi Studio]** — Download Pre-built releases for Windows, Linux and Mac OS.
* **[Get Plugins]** — Add additional functionality.
* **[Get Color Themes]** — Additional color themes (bundled with all releases
of Avi Studio by default).

A list of changes is registered on the [changelog] file. Please refer to our
[website] for the user and developer [documentation], including more detailed
[build] instructions.
---

## What is Avi Studio?

Avi Studio aims to be the main tool for developers writing skills for Avi:

* Write Avi DSL code
* Organise skills as projects
* Test and validate skills locally
* Upload skills to an Avi device
* Publish skills to a shared repository

Right now, only the first step exists.

---

## Current Features

* Syntax highlighting for the **Avi DSL**

That’s it. Everything else is planned.

---

## Planned Features

* `make skill` command / wizard
* Skill project templates
* Skill validation and linting
* Local testing tools
* Upload skills directly to Avi devices
* Repository integration (store, fetch, publish skills)
* Better language tooling (intents, triggers, actions)

The scope will grow as Avi itself evolves.

---

## Tech Stack

* **C** — editor core (via Pragtical / Lite XL)
* **Lua** — editor logic, plugins, language support

If you’ve worked with Lite XL before, you’ll feel at home.

---

## Building

First Run to compile the Executable: 

```
./build-packages.sh -P -f
```

Then if avi-studio folder is not generated, run:
```
bash scripts/package.sh --version dev (build folder) --addons --debug --binary --release
```

---

## Contributing

Contributions are welcome, especially:

* Avi DSL tooling
* Editor plugins (Lua)
* UX improvements
* Documentation

Expect breaking changes. This is still moving fast.

---

## Project Status

> Avi Studio is under active development.
> APIs, formats, and workflows may change at any time.

---

## License

License information will be added.
