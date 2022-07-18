# Flutter Architecture Examples

A collection of opinionated project architectures for Flutter apps.

## Overview

Layered Architecture

![layered](.github/images/layered.png)

## Usage

### Setting up the projects

Select an example project below. To download its dependencies, run:

```
make pub app=<example_app>
```

For example,

```
make pub app=mobx
```

Or, download the dependencies for all projects:

```
make pubs
```

### Running the project

Select an example project below and run:

```
make run app=<example_app>
```

For example,

```
make run app=mobx
```


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