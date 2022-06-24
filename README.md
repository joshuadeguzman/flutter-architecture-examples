# Flutter Architecture Examples

A collection of opinionated project architectures for Flutter apps.

## Overview

Layered Architecture

![layered](.github/images/layered.png)

## Examples

###  MobX Architecture
**Overview**

![mobx](.github/images/mobx.png)

**Project Structure**
```
core
└── data
    ├── api
    ├── models
    ├── local
    └── remote
├── domain
├── widgets (common components)
└── repositories
feature
├── presentation
├── views
└── widgets
```

**See [MobX + REST example](https://github.com/joshuadeguzman/flutter-architecture-examples/tree/main/mobx) or [MobX + GraphQL example](https://github.com/joshuadeguzman/flutter-architecture-examples/tree/main/mobx_graphql).**