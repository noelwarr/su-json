#Self made implementation of a JSON parser and generator.

class JSON

  def initialize(hash)
    raise ArgumentError, "Hash required" unless hash.is_a?(Hash)
    @hash = hash
  end

  def inspect
    "<JSON:0x#{(self.object_id << 1 ).to_s(16)}>"
  end

  def to_s
    stringify(@hash)
  end

  def self.parse(input)
    raise "JSON could not parse empty string" if input == ""
    first_character, last_character = input[0,1], input[-1,1]
    result = case first_character + last_character
    when '[]' then parse_object(input)
    when '{}'
      hash = Hash[*parse_object(input)]
      symbolized_hash = Hash.new
      hash.each{|k,v| symbolized_hash[k.to_sym] = v}
      symbolized_hash
    when '""' then parse_string(input)
    else
      case input
      when 'true' then true
      when 'false' then false
      when 'null' then nil
      else
        parse_numeric(input)
      end
    end
    result
  end

  private

  def stringify(input)
    output = nil
    if input.is_a? String
      output = input.dump    
    elsif input.is_a? Array
      output = "[#{(input.collect{|object| stringify(object)}).join(",")}]"
    elsif input.is_a? Hash
      output = "{#{(input.to_a.collect{|key,value| "#{stringify(key)}:#{stringify(value)}"}).join(",")}}"
    elsif input.is_a? Symbol
      output = input.to_s.dump
    elsif input.is_a? NilClass
      output = "null"
    else
      output = input.to_s
    end
    return output
  end

  def self.parse_string(input)
    escaped = false
    input[1..-2].each_byte{|b| c = b.chr          
      if c == '\\'
        escaped = !escaped
      elsif c == '"' && !escaped 
        raise "JSON could not parse #{input}"
      end
      eval(input)
    }
  end

  def self.parse_object(input)
    depth = 0
    in_string = false
    escaped = false
    result = Array.new
    buffer = String.new
    input[1..-2].each_byte{|b| c = b.chr
      buffer += c
      if in_string 
        if c == '"'         
          in_string = !in_string
        elsif c == '\\'
          escaped = true
        else
          escaped = false
        end
      elsif !in_string && c == '"'
        in_string = !in_string
      else
        case c
        when "[", "{" then depth +=  1
        when "]", "}" then depth += -1
        when ":", ","
          if depth == 0
            result.push parse(buffer.chop)
            buffer = String.new
          end
        end
      end
    }
    buffer.empty? ? [] : result.push(parse(buffer))
  end

  def self.parse_numeric(input)
    raise "JSON could not parse #{input}" if input.match(/[^eE0-9\.+-]/)
    case input.count(".")
    when 0 then input.to_i
    when 1 then input.to_f
    end
  end


end