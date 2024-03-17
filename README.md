# raylib-quickjsx - Javascript + JSX + Raylib

QuickJS based Javascript + JSX bindings for raylib in a single executable

## What is this?

- raylib-quickjsx is small ES2020 compliant Javascript interpreter based on [QuickJS](https://bellard.org/quickjs/) with bindings for [Raylib](https://www.raylib.com/) and . You can use it to develop desktop games with Javascript.
- [QuickJSPP](https://github.com/ftk/quickjspp.git) - QuickJSPP is QuickJS wrapper for C++. (not used directly)
- [QuickJSPP + JSX fork](https://github.com/c-smile/quickjspp.git) - QuickJSPP plus JSX and Persistence

### Scope

- The goal of this library is to build overlay systems in those places where browser based engines are too heavy or even forbidden.

### Build with cmake

Make sure you have cmake installed and in your path.

```shell
cd raylib-quickjsx
./build-all.sh
```

See [`build-all.sh`](./build-all.sh) to understand how to integrate
