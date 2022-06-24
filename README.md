# Flutter Architecture Examples

An opinionated architecture collection when building Flutter Apps.

## Overview

Layered Architecture

![layered](.github/images/layered.png)

## Examples

###  MobX Architecture
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

