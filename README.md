# flutter_coverage_badge

Flutter Coverage Badge
![Coverage](https://raw.githubusercontent.com/fernandomoraesvr/flutter_coverage_badge/main/coverage_badge.svg?sanitize=true)


## Getting Started

### Install

```
dev_dependencies:
  flutter_coverage_badge:
    git:
      url: git@github.com:fernandomoraesvr/flutter_coverage_badge.git
      ref: main
```

```
flutter pub get
```


### Run Test with Coverage

```
flutter test --coverage
```

### Generate badge image

```
flutter pub run flutter_coverage_badge
```

![Coverage](https://raw.githubusercontent.com/fernandomoraesvr/flutter_coverage_badge/main/coverage_badge.svg?sanitize=true)

```
![Coverage](https://raw.githubusercontent.com/{you}/{repo}/master/coverage_badge.svg?sanitize=true)
```

### Specify input path
```
Default input path: coverage/lcov.info

flutter pub run flutter_coverage_badge -i 'coverage/new_lcov.info'
```
### Specify output filename
```
The coverage badge output path is always generated at .github/badges, but you can specify a different filename.

Default output filename: coverage_badge.svg

flutter pub run flutter_coverage_badge -o 'coverage.svg'

```





