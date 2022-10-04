# any-jump lang map build process

## source for lang definition
https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el

## step 1: download .el file and extract definitions
```
bundle exec rake download
```

## step 2: generate lang_map.el
```
bundle exec rake generate
```

## step 3: install lang_map.el to autoload/lang_map.vim
```
bundle exec rake install
```

## all steps together:
```
bundle exec rake update
```
