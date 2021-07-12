# any-jump.vim

**— IDE madness without overhead for 40+ languages**

_Vim code inspection plugin for finding definitions⚒ and references/usages🔬._

Any-jump can be used with any language, but definitions search only available for supported languages. This is not a problem in general, so use any-jump freely on any code project.


Based on syntax rules for 40 languages and **fast regexp engines** like ripgrep and ag.

<p align="center">
  <img src="https://github.com/pechorin/any-jump.vim/raw/master/main.gif"/>
</p>
<p align="center"><i>On screen: jumping through source code of Discourse project</i></p>


## Requirements

- `nvim 0.4+` or `vim 8.2`
- `ripgrep 11.0.0+` or `ag`
- _some languages requires rg with PCRE2 support_

## Installation

via vim-plug:

```viml
Plug 'pechorin/any-jump.vim'
```

## Usage

In normal or visual mode.

Just place you cursor on any variable/class/constant/name/symbol and press `<leader>j` or execute `:AnyJump` in normal mode.
You can also use visual mode to select proper keyword (<leader>j also works in visual mode)

With `:AnyJumpArg myKeyword` command you can manually write what you want to be searched for.

## Searches

- **keyword definitions**: find files where keyword defined

- **keyword references/usages**: find files where keyword used and referenced

## version 1.0 roadmap

- [ ] paths priorities for better search results
- [ ] [nvim] ability to jump through preview text (and another keyword)
- [ ] show latest N search keywords in popup to save jumping history
- [ ] ctags support
- [ ] basic refactoring support

## Keybindings

Default global mappings for normal and visual modes:

```viml
" Normal mode: Jump to definition under cursor
nnoremap <leader>j :AnyJump<CR>

" Visual mode: jump to selected text in visual mode
xnoremap <leader>j :AnyJumpVisual<CR>

" Normal mode: open previous opened file (after jump)
nnoremap <leader>ab :AnyJumpBack<CR>

" Normal mode: open last closed search window again
nnoremap <leader>al :AnyJumpLastResults<CR>
```

Disabling default any-jump keybindings:

```viml
let g:any_jump_disable_default_keybindings = 1
```

Mappings for popup search window

```
o/<CR>     open
s          open in split
v          open in vsplit
t          open in new tab
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
let g:any_jump_max_search_results = 10

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

" Customize any-jump colors with extending default color scheme:
" let g:any_jump_colors = { "help": "Comment" }

" Or override all default colors
let g:any_jump_colors = {
      \"plain_text":         "Comment",
      \"preview":            "Comment",
      \"preview_keyword":    "Operator",
      \"heading_text":       "Function",
      \"heading_keyword":    "Identifier",
      \"group_text":         "Comment",
      \"group_name":         "Function",
      \"more_button":        "Operator",
      \"more_explain":       "Comment",
      \"result_line_number": "Comment",
      \"result_text":        "Statement",
      \"result_path":        "String",
      \"help":               "Comment"
      \}

" Disable default any-jump keybindings (default: 0)
let g:any_jump_disable_default_keybindings = 1

" Remove comments line from search results (default: 1)
let g:any_jump_remove_comments_from_results = 1

" Custom ignore files
" default is: ['*.tmp', '*.temp']
let g:any_jump_ignored_files = ['*.tmp', '*.temp']

" Search references only for current file type
" (default: false, so will find keyword in all filetypes)
let g:any_jump_references_only_for_current_filetype = 0

" Disable search engine ignore vcs untracked files
" (default: false, search engine will ignore vcs untracked files)
let g:any_jump_disable_vcs_ignore = 0
```

## Theme configuration

There are default theme configuration based on standard Vim highlight groups,
you can override any setting:

```
let g:any_jump_colors = {
      \"plain_text":         "Comment",
      \"preview":            "Comment",
      \"preview_keyword":    "Operator",
      \"heading_text":       "Function",
      \"heading_keyword":    "Identifier",
      \"group_text":         "Comment",
      \"group_name":         "Function",
      \"more_button":        "Operator",
      \"more_explain":       "Comment",
      \"result_line_number": "Comment",
      \"result_text":        "Statement",
      \"result_path":        "String",
      \"help":               "Comment"
      \}
```

### Background settings

You can set non-theme background by set Pmenu hl group like this:

```
hi Pmenu guibg=#1b1b1b ctermbg=Black
```

Where are also `PmenuSel`, `PmenuSbar`, `PmenuThumb` groups for configuring.

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

## Issues and contributions

Please open issue on any question / problem / feedback / idea.

Guaranteed contribution feedback: 3-5 days, but it's stable.

```
 /~~||/~\\  /---   ||   ||/~\ /~\ |~~\
 \__||   |\/       | \_/||   |   ||__/
         _/     \__|              |
```
