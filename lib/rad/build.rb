require 'erb'
require 'ostruct'

class Rad::Build
  class << self
    attr_accessor :sketch_name
  end
  def self.run

    options, parser = OptionParser.parse(ARGV)
    @sketch_name = ARGV[0]
    parser.parse!(["-h"]) unless @sketch_name

    vendor_rad
    libraries
    examples
    test
    plugins
    sketch
    rake_file
    config
    text
  end

  def self.vendor_rad
    FileUtils.mkdir_p "#{@sketch_name}/vendor/rad"
    FileUtils.cp_r RAD_LIB.join('rad'), "#{@sketch_name}/vendor"
  end
  
  def self.libraries
    FileUtils.mkdir_p "#{@sketch_name}/vendor/libraries"
    application_dir = Pathname.new($config['arduino']['application_dir'][$config['os']])
    src = application_dir.join($config['arduino']['version'],'libraries')
    dest = "#{@sketch_name}/vendor"
    FileUtils.cp_r src, dest
  end

  def self.examples
    FileUtils.mkdir_p "#{@sketch_name}/examples"
    FileUtils.cp_r RAD_LIB.join('examples'), "#{@sketch_name}/"
  end
  
  def self.test
    # Build test -- used testing
    
    # FIXME: this should put the tests into the vendor/tests directory instead.
    
    # FileUtils.mkdir_p "#{@sketch_name}/test"
    # puts "Successfully created your test directory."
    #
    # FileUtils.cp_r "#{File.dirname(__FILE__)}/../lib/test/.", "#{@sketch_name}/test"
    # puts "Installed tests into #{@sketch_name}/test"
    # puts
  end

  def self.plugins
    FileUtils.mkdir_p "#{@sketch_name}/vendor/plugins"
    FileUtils.cp_r RAD_LIB.join('plugins'), "#{@sketch_name}/vendor"
  end
  
  def self.sketch
    FileUtils.mkdir_p "#{@sketch_name}/#{@sketch_name}"
    FileUtils.touch "#{@sketch_name}/#{@sketch_name}.rb"
    #todo dry and use to_camelcase
    sketch_name_cc = @sketch_name.split("_").collect{|c| c.capitalize}.join("")
    template = File.read(RAD_LIB + 'templates' + 'sketch.erb')
    erb = ERB.new(template)
    File.open("#{@sketch_name}/#{@sketch_name}.rb", "w") do |file|
      file.write erb.result(binding)
    end
  end

  def self.rake_file
    FileUtils.touch "#{@sketch_name}/Rakefile"
    template = File.read(RAD_LIB + 'templates' + 'Rakefile.erb')
    erb = ERB.new(template)
    File.open("#{@sketch_name}/Rakefile", 'w') do |file|
      file.write erb.result(binding)
    end
  end
  
  def self.config
    FileUtils.mkdir_p "#{@sketch_name}/config"
    File.open("#{@sketch_name}/config/hardware.yml", 'w') do |file|
      file << "##############################################################
    # Today's MCU Choices (replace the mcu with your arduino board)
    # atmega8 => Arduino NG or older w/ ATmega8
    # atmega168 => Arduino NG or older w/ ATmega168
    # mini => Arduino Mini
    # bt  => Arduino BT
    # diecimila  => Arduino Diecimila or Duemilanove w/ ATmega168
    # nano  => Arduino Nano
    # lilypad  => LilyPad Arduino
    # pro => Arduino Pro or Pro Mini (8 MHz)
    # atmega328 => Arduino Duemilanove w/ ATmega328
    # mega => Arduino Mega

      "
      file << options["hardware"].to_yaml
    end
    
    File.open("#{@sketch_name}/config/software.yml", 'w') do |file|
      file << options["software"].to_yaml
    end
  end

  def self.text
    puts "Run 'rake -T' inside your sketch dir to learn how to compile and upload it."
    puts "Default configuration: 'diecimila', to change goto config/hardware"
    puts "Don't forget to install the drivers."
    puts "Run rad install to upgrade."
  end

end