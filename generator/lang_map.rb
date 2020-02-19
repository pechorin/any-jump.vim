require 'rubygems'
require 'bundler/setup'

require 'json'
require 'sxp'
require 'uri'
require 'net/http'

LISP_LANG_MAP_PATH = Dir.pwd + '/lang_map.el'

unless File.exists?(LISP_LANG_MAP_PATH)
  throw "file not found -> #{LISP_LANG_MAP_PATH}"
end

lisp  = File.read(LISP_LANG_MAP_PATH)
sexps = SXP.read(lisp)

unless sexps.is_a?(Array)
  raise RuntimeError, "No sexps found"
end

puts "Total sexps rules => #{ sexps.count.to_s }\n\n"

LOOKUP_KEYS_TRANSFORM = {
  :":type"     => :type,
  :":supports" => :supports,
  :":language" => :language,
  :":regex"    => :regex,
  :":tests"    => :tests,
  :":not"      => :not
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

sexps.each_with_index do |defi, i|
  result = process_definition(defi)
  next unless result

  puts "#{i} -> #{defi} \n\n Result -> #{result} \n\n-----------------------------------"
end
