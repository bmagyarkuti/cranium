class Cranium::Application

  include Cranium::Logging

  attr_reader :sources



  def initialize(arguments)
    @sources = Cranium::SourceRegistry.new
    @hooks = {}

    @options = Cranium::CommandLineOptions.new arguments
  end



  def load_arguments
    options.load_arguments
  end



  def register_source(name, &block)
    @sources.register_source(name, &block).resolve_files
  end



  def run
    process_file = validate_file options.cranium_arguments[:load]

    load_initializer(options.cranium_arguments[:initializer])

    log :info, "Process '#{process_name(process_file)}' started"

    begin
      load process_file
    rescue Exception => ex
      log :error, ex
      raise
    ensure
      log :info, "Process '#{process_name(process_file)}' finished"
    end
  end



  def after_import(&block)
    @hooks[:after_import] ||= []
    @hooks[:after_import] << block
  end



  def apply_hook(name)
    unless @hooks[name].nil?
      @hooks[name].each do |block|
        block.call
      end
    end
  end



  private

  attr_reader :options



  def validate_file(load_file)
    exit_if_no_file_specified load_file
    exit_if_no_such_file_exists load_file
    load_file
  end



  def exit_if_no_file_specified(file)
    if file.nil? || file.empty?
      $stderr.puts "ERROR: No file specified"
      exit 1
    end
  end



  def exit_if_no_such_file_exists(file)
    unless File.exists? file
      $stderr.puts "ERROR: File '#{file}' does not exist"
      exit 1
    end
  end



  def load_initializer(initializer)
    return unless initializer

    exit_if_no_such_file_exists initializer
    load initializer
  end



  def process_name(file_name)
    File.basename(file_name, File.extname(file_name))
  end

end
