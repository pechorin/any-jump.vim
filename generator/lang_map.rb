require 'json'
require 'sxp'
require 'uri'
require 'net/http'

el_path = Dir.pwd + '/generator/lang_map.el'

unless File.exists?(el_path)
  throw "file not found -> #{el_path}"
end

el_scp = File.read(el_path)
sexps  = SXP.read(el_scp)[3]

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
