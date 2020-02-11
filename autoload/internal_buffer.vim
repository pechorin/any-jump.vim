" ----------------------------------------------
" Internal buffer prototype definition
" ----------------------------------------------
" represents ui internal structure

" abstract structure of internal buffer representation:
"
" buffer = [ array of lines ]
"
" line = [ list of items
"   { type, strat_col, finish_col, text, hl_group },
"   { ... },
"   ...
" ]
let s:InternalBuffer = {}

let s:InternalBuffer.MethodsList = [
      \'RenderLine',
      \'AddLine',
      \'AddLineAt',
      \'CreateItem',
      \'len',
      \'GetItemByPos',
      \'GetItemLineNumber',
      \]

" Produce new Render Buffer
fu! s:InternalBuffer.New() abort
  let object = {
        \"items": [],
        \"preview_opened": 0 }

  for method in self.MethodsList
    let object[method] = s:InternalBuffer[method]
  endfor

  return object
endfu

fu! s:InternalBuffer.len() dict abort
  return len(self.items)
endfu

fu! s:InternalBuffer.RenderLine(items, line) dict abort
  let base_prefix = "\t"
  let text        = base_prefix
  let hl_regions  = []

  for item in a:items
    let prefix = ""

    if item.start_col > 0
      let prefix = repeat(" ", item.start_col)
    endif

    let hl_from = item.start_col + len(text)
    let hl_to   = hl_from + len(prefix . item.text)
    let text    = text . prefix . item.text

    call add(hl_regions, [item.hl_group, hl_from, hl_to])
  endfor

  call appendbufline(bufnr(), a:line, text)

  for region in hl_regions
    call nvim_buf_add_highlight(
          \bufnr(),
          \-1,
          \region[0],
          \a:line,
          \region[1],
          \region[2])
  endfor
endfu

fu! s:InternalBuffer.AddLine(items) dict abort
  if type(a:items) == v:t_list
    let current_len = self.len()

    call self.RenderLine(a:items, current_len)
    call add(self.items, a:items)

    return v:true
  else
    echoe "array required, got invalid type: " . string(a:items)

    return v:false
  endif
endfu

fu! s:InternalBuffer.AddLineAt(items, line_number) dict abort
  if type(a:items) == v:t_list
    call self.RenderLine(a:items, a:line_number)
    call insert(self.items, a:items, a:line_number)

    return v:true
  else
    echoe "array required, got invalid type: " . string(a:items)

    return v:false
  endif
endfu

" type:
"   'text' / 'link' / 'button' / 'preview_text'
fu! s:InternalBuffer.CreateItem(type, text, start_col, end_col, hl_group, ...) dict abort
  let data = 0

  if a:0 > 0
    let data = a:1
  endif

  let item = {
        \"type":      a:type,
        \"text":      a:text,
        \"start_col": a:start_col,
        \"end_col":   a:end_col,
        \"hl_group":  a:hl_group,
        \"gc":        0,
        \"data":      data
        \}
  return item
endfu


fu! s:InternalBuffer.GetItemByPos() dict abort
  let idx = line('.') - 1

  if len(self.items) == idx
    return 0
  endif

  let column = col('.')
  let line   = self.items[idx]

  for item in line
    if item.start_col <= column && (item.end_col >= column || item.end_col == -1 )
      return item
    endif
  endfor

  return 0
endfu

" not optimal, but ok for current ui with around ~100/200 lines
" COMPLEXITY: N+1
" TODO: add index like structure
fu! s:InternalBuffer.GetItemLineNumber(item) dict abort
  let i = 1
  for line in self.items
    for item in line
      if item == a:item
        return i
      endif
    endfor

    let i += 1
  endfor

  return 0
endfu

" Public api
fu! internal_buffer#GetClass() abort
  return s:InternalBuffer
endfu
