# MinimaOS

![Makefile CI](https://github.com/srwxr-xr-x/MinimaOS/actions/workflows/makefile.yml/badge.svg)
![](https://raw.githubusercontent.com/srwxr-xr-x/MinimaOS/trunk/Images/Main.png)
## Setup

> **Note** -
> compilation is guaranteed only on linux & co, but
> it is also possible in windows with virtualization
> solutions like wsl (on windows 11) or hyperV

### Makefile Information

```bash
# Install dependencies (Only on a distro using apt)
make dep

# Build all temporary and permanent files
make

# Build all and run
make run

# Clean intermediary files
make clean

# Show all commands
make info
```


## Source & Acknowledgment
* [limine-barebones](https://github.com/limine-bootloader/limine-barebones) for the original kernel code
* [OSDev Wiki](https://wiki.osdev.org/) for yet more gory introductory details
* [irc.libera.chat:#osdev](https://libera.irclog.whitequark.org/osdev)
