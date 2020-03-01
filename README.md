# any-jump

**— IDE madness without overhead for 40+ languages**

_Vim plugin for "jump to defitinition⚒" and "find usages🔬" feature through nice popup ui_

**nvim 0.4+ or vim 8.2+ required**

Based on syntax rules for 40 languages and **fast regexp engines** like ripgrep and ag. Required `rg` or `ag` to be installed. GNU grep support dropped for flavor of blazing perfomance (can be implemented in future releases).

![screenshot](/main.gif)

_On screen: jumping through source code of Discourse project_

![vim-support](https://user-images.githubusercontent.com/226270/75636019-104cb380-5c2c-11ea-9730-70db71bac35f.png)

_On screen: running Any-jump on vim 8.2_

## Installation

via vim-plug:

```viml
Plug 'pechorin/any-jump.nvim'
```

## Run

Just place you cursor on any variable / class name/ definition and do `<leader>j` or via command line `:AnyJump`.
You will run search and see any-jump popup window with results.

Where a two types of search results now: definitions and usages.

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

```viml
au FileType any-jump nnoremap <buffer> o :call g:AnyJumpHandleOpen()<cr>
au FileType any-jump nnoremap <buffer><CR> :call g:AnyJumpHandleOpen()<cr>
au FileType any-jump nnoremap <buffer> p :call g:AnyJumpHandlePreview()<cr>
au FileType any-jump nnoremap <buffer> <tab> :call g:AnyJumpHandlePreview()<cr>
au FileType any-jump nnoremap <buffer> q :call g:AnyJumpHandleClose()<cr>
au FileType any-jump nnoremap <buffer> <esc> :call g:AnyJumpHandleClose()<cr>
au FileType any-jump nnoremap <buffer> u :call g:AnyJumpHandleUsages()<cr>
au FileType any-jump nnoremap <buffer> U :call g:AnyJumpHandleUsages()<cr>
au FileType any-jump nnoremap <buffer> b :call g:AnyJumpToFirstLink()<cr>
au FileType any-jump nnoremap <buffer> T :call g:AnyJumpToggleGrouping()<cr>
au FileType any-jump nnoremap <buffer> a :call g:AnyJumpToggleAllResults()<cr>
au FileType any-jump nnoremap <buffer> A :call g:AnyJumpToggleAllResults()<cr>
```

## Settings

```viml
" Show line numbers in search rusults
let g:any_jump_list_numbers = 0

" Auto search usages
let g:any_jump_usages_enabled = 1

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

" Disable default any-jump keybindings
let g:any_jump_disable_default_keybindings = 1 " default is false
```

## Features

### open definitions and usages list

![screenshot](/usages.png)

### preview definition with `p` or `tab`

![screenshot](/preview.png)

### group results by file

![screenshot](/group_by_file.png)

### search results without line numbers and different ui style

![screenshot](/no_ln.png)

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

Please open issue on any question and problem
