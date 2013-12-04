#!/usr/bin/ruby
require 'plist'

#TODO select color, etc.

%w{
   attribute
   character
   comment
   comment.doc
   comment.doc.keyword
   identifier.class
   identifier.class.system
   identifier.constant
   identifier.constant.system
   identifier.function
   identifier.function.system
   identifier.macro
   identifier.macro.system
   identifier.type
   identifier.type.system
   identifier.variable
   identifier.variable.system
   keyword
   number
   plain
   preprocessor
   string
   url
}

class String
  def parts
    split(' ')[0..2].map{|n| (n.to_f * 255.0).round }
  end
  def rgba
    '#' + parts.map{|n| "%02x" % n}.join('').upcase
  end
  def dark?
    r,g,b = parts.map{|n| n.to_f }
    percievedLuminance = 1 - (((0.299 * r) + (0.587 * g) + (0.114 * b)) / 255)
    percievedLuminance >= 0.5
  end
  def border
    a = "0.25"
    if not dark?
      "rgba(0,0,0,#{a})"
    else
      "rgba(255,255,255,#{a})"
    end
  end
end

theme_name = File.basename(ARGV.first, '.dvtcolortheme')

plist = Plist::parse_xml(ARGV.first)
bg = plist['DVTSourceTextBackground']
puts <<-EOS
.#{theme_name} {
  background: #{bg.rgba};
  color: #{plist['DVTSourceTextSyntaxColors']['xcode.syntax.plain'].rgba};
  border-color: #{bg.border};
}
EOS

plist.fetch('DVTSourceTextSyntaxColors').each do |key, value|
  key = key.sub(/^xcode\.syntax\./, '')
  key = case key
  when 'comment', 'number', 'keyword', 'preprocessor', 'string'
    key
  when 'identifier.function', 'identifier.class'
    key.sub(/^identifier\./, '')
  when 'identifier.variable.system'
    'variable'
  when 'identifier.variable'
    'ivar'
  else
    nil
  end
  puts ".#{theme_name} .#{key} { color: #{value.rgba} }" if key
end
