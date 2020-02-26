require 'rubygems'
require 'bundler/setup'

require 'json'
require 'sxp'

unless ENV["IN"]
  throw "input file not specified via IN"
end

unless ENV["OUT"]
  throw "output file not specified via OUT"
end

unless File.exists?(ENV['IN'])
  throw "file not found -> #{ENV['IN']}"
end

lisp  = File.read(ENV['IN'])
sexps = SXP::Reader::Basic.read(lisp)

unless sexps.is_a?(Array)
  raise RuntimeError, "No sexps found"
end

puts "Total sexps rules to import: #{ sexps.count.to_s }\n\n"

LOOKUP_KEYS_TRANSFORM = {
  :":type"     => :type,
  :":supports" => :supports,
  :":language" => :language,
  :":regex"    => :emacs_regexp,
  :":tests"    => :spec_success,
  :":not"      => :spec_failed
}

LOOKUP_KEYS   = LOOKUP_KEYS_TRANSFORM.keys
COMMENT_START = :";;"

def process_definition(def_array)
  return unless def_array.is_a?(Array)
  result = {}

  next_type = nil

  for e in def_array
    # comment or key definition
    if e == COMMENT_START
      next_type = :comment
      next
    elsif LOOKUP_KEYS.include?(e)
      next_type = LOOKUP_KEYS_TRANSFORM[e]
      next
    end

    # comment body or key value
    if next_type == :comment
      next
    elsif next_type != nil
      result[next_type] = e
      next_type = nil
      next
    end
  end

  return result
end

def definitions_viml
  r = <<~STR
    " NOTES:
    " - all language regexps ported from https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el

    let s:definitions = {}

    fu! s:add_definition(lang, definition) abort
      if !has_key(s:definitions, a:lang)
        let s:definitions[a:lang] = []
      endif

      call add(s:definitions[a:lang], a:definition)
    endfu

    fu! lang_map#find_definitions(language) abort
      if !lang_map#lang_exists(a:language)
        return
      endif

      return s:definitions[a:language]
    endfu

    fu! lang_map#definitions() abort
      return s:definitions
    endfu

    fu! lang_map#lang_exists(language) abort
      return has_key(s:definitions, a:language)
    endfu
  STR

  return r
end

def pcre2_regexp(string)
  string = string.dup.to_s

  string.gsub!('JJJ', 'KEYWORD')
  string.gsub!('\\j', '($|[^a-zA-Z0-9\\?\\*-])')

  return string
end

def convert_definition_to_viml(hash = {})
  # puts hash[:emacs_regexp].dump
  r = "\n"
  r << "call s:add_definition('#{hash[:language]}', {\n"
  r << "\t" + '\"type": ' + "'" + hash[:type] + "',\n"
  r << "\t" + '\"pcre2_regexp": ' + "'" + pcre2_regexp(hash[:emacs_regexp]) + "',\n"
  r << "\t" + '\"emacs_regexp": ' + "'" + hash[:emacs_regexp].to_s + "',\n"
  r << "\t" + '\"supports": ' + hash[:supports].to_s + ",\n"
  r << "\t" + '\"spec_success": ' + hash[:spec_success].to_a.to_json + ",\n"
  r << "\t" + '\"spec_failed": '  + hash[:spec_failed].to_a.to_json + ",\n"
  r << "\t" + "\\})\n"

  return r
end

vimscript = ""
vimscript << definitions_viml()

sexps.each_with_index do |sexp, i|
  result = process_definition(sexp)
  next unless result
  next if result.empty?

  viml_definition = convert_definition_to_viml(result)
  vimscript << viml_definition
end

outfile = File.new(ENV['OUT'], 'w')
outfile.print(vimscript)
outfile.close
