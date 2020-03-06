# any-jump.vim

**— IDE madness without overhead for 40+ languages**

_Vim plugin for jumping to defitinitions⚒ and references/usages🔬 through nice ui._

**nvim 0.4+ or vim 8.2+ required**

Based on syntax rules for 40 languages and **fast regexp engines** like ripgrep and ag. Required `rg` or `ag` to be installed. GNU grep support dropped for flavor of blazing perfomance (can be implemented in future releases).

**Currently rg results is much better, please use rg. Will try to fix this soon.**

<p align="center">
  <img src="https://github.com/pechorin/any-jump.vim/raw/master/main.gif"/>
</p>

_On screen: jumping through source code of Discourse project_

## Installation

via vim-plug:

```viml
Plug 'pechorin/any-jump.vim'
```

## Usage

Just place you cursor on any variable/class/constant/name/symbol and press `<leader>j` or execute `:AnyJump` in normal mode.

## Searches

- **keyword definitions**: find files where keyword defined

- **keyword references/usages**: find files where keyword used and referenced

- _ctags: not implemeneted now, but planned_

- ...

## Keybindings

Default global mappings for normal mode:

```viml
" Jump to definition under cursore
nnoremap <leader>j :AnyJump<CR>

" open previous opened file (after jump)
nnoremap <leader>ab :AnyJumpBack<CR>

" open last closed search window again
nnoremap <leader>al :AnyJumpLastResults<CR>
```

Disabling default any-jump keybindings:

```viml
let g:any_jump_disable_default_keybindings = 1
```

Mappings for popup search window

```
o/<CR>     open link
p/<tab>    preview
q/x        exit
r          references
b          back to first result
T          group by file
a          load next N results
A          load all results
L          toggle results lists ui style
```

## Settings

```viml
" Show line numbers in search rusults
let g:any_jump_list_numbers = 0

" Auto search references
let g:any_jump_references_enabled = 1

" Auto group results by filename
let g:any_jump_grouping_enabled = 0

" Amount of preview lines for each search result
let g:any_jump_preview_lines_count = 5

" Max search results, other results can be opened via [a]
let g:any_jump_max_search_results = 7

" Prefered search engine: rg or ag
let g:any_jump_search_prefered_engine = 'rg'


" Search results list styles:
" - 'filename_first'
" - 'filename_last'
let g:any_jump_results_ui_style = 'filename_first'


" Any-jump window size & position options
let g:any_jump_window_width_ratio  = 0.6
let g:any_jump_window_height_ratio = 0.6
let g:any_jump_window_top_offset   = 4

" Disable default any-jump keybindings (default: 0)
let g:any_jump_disable_default_keybindings = 1

" Remove comments line from search results (default: 1)
let g:any_jump_remove_comments_from_results = 1

" Cursor keyword selection mode
"
" on line:
"
" "MyNamespace::MyClass"
"                  ^
"
" then cursor is on MyClass word
"
" 'word' - will match 'MyClass'
" 'full' - will match 'MyNamespace::MyClass'

let g:any_jump_keyword_match_cursor_mode', 'word'

" Add ignore files
call g:AnyJumpAddIgnoredFile('*.tmp')
call g:AnyJumpAddIgnoredFile('*.temp')
call g:AnyJumpAddIgnoredFile('tags')

" Search references only for current file type
" (default: false, so will find keyword in all filetypes)
let g:any_jump_references_only_for_current_filetype = 0

```

## Features

### open definitions and references/usages list

![screenshot](/usages.png)

### preview definition with `p` or `tab`

![screenshot](/preview.png)

### group results by file

![screenshot](/group_by_file.png)

### search results with line numbers

![screenshot](/with_ln.png)

### vim 8.2 inside terminal

![vim-support](https://user-images.githubusercontent.com/226270/75636019-104cb380-5c2c-11ea-9730-70db71bac35f.png)

## Supported languages

- ruby
- elixir
- crystal
- rust
- haskell
- java
- javascript
- typescript
- scala
- kotlin
- php
- protobuf
- scss
- fsharp
- c++
- coffeescript
- go
- lua
- nim
- scad
- elisp
- nix
- clojure
- coq
- systemverilog
- objc
- racket
- vhdl
- scheme
- r
- sql
- faust
- vala
- matlab
- python
- pascal
- tex
- swift
- shell
- perl
- csharp
- commonlisp
- ocaml
- erlang
- julia
- sml
- groovy
- dart
- fortran

## Original idea

Comes from dumb-jump.el emacs package

## Issues and contibutions

Please open issue on any question / problem / feedback / idea.

```
 /~~||/~\\  /---   ||   ||/~\ /~\ |~~\
 \__||   |\/       | \_/||   |   ||__/
         _/     \__|              |
```
