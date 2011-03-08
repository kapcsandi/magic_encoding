# -*- encoding : utf-8 -*-

# A simple library to prepend magic comments for encoding to multiple ".rb" files

require 'magic_encoding/version'

module AddMagicComment
  # Options :
  # --encoding, -e ENCODING: Encoding
  # Default is utf-8
  #
  # --path, -p PATH: Path
  # Default is . (current directory)
  #
  # --files, -f FILES: File glob parameters. Eg. *.erb
  # Default is *.rb
  #
  # TODO : check that the encoding specified is a valid encoding
  def self.process(options)

    # defaults
    opts = OpenStruct.new
    opts.encoding  = "utf-8"
    opts.directory = Dir.pwd
    opts.files = "*.rb"


    OptionParser.new do |o|
      o.banner = "Usage: magic_encoding [options]"
      o.on("-e", "--encoding [ENCODING]", "Sets encoding to other than utf-8") do |e|
        opts.encoding = e || opts.encoding
      end

      o.on("-p", "--path [PATH]", "Sets search path to other than current directory") do |d|
        opts.path = d || opts.path
      end

      o.on("-f", "--files [FILES]", "Sets the file search glob parameter to other than *.rb") do |f|
        opts.files = f || opts.files
      end

      o.on("-v", "--version", "Prints version info") do
        puts 'v' + VERSION
        exit
      end
      o.on("-h", "--help", "This help") do
        puts o
        exit
      end
    end.parse! options

    prefix = "# -*- encoding : #{opts.encoding} -*-\n"

    # TODO : add options for recursivity (and application of the script to a single file)
    rbfiles = File.join(opts.directory ,"**", opts.files)
    Dir.glob(rbfiles).each do |filename|
      file = File.new(filename, "r+")

      lines = file.readlines

      # remove current encoding comment(s)
      while lines[0] && (
            lines[0].starts_with?("# encoding") || 
            lines[0].starts_with?("# coding") ||
            lines[0].starts_with?("# -*- encoding"))
        lines.shift
      end

      # set current encoding
      lines.insert(0,prefix)

      file.pos = 0
      file.puts(lines.join) 
      file.close
    end
    puts "Magic comments set for #{Dir.glob(rbfiles).count} source files"
  end

end

class String

  def starts_with?(s)
    self[0..s.length-1] == s
  end

end




