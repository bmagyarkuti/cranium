class Cranium::Application

  include Cranium::Logging

  attr_reader :sources



  def initialize
    @sources = Cranium::SourceRegistry.new
    @hooks = {}
  end



  def register_source(name, &block)
    @sources.register_source name, &block
  end



  def run(args)
    process_file = validate_file_in_arguments args

    start_time = Time.now
    begin
      load process_file
    rescue Exception => ex
      log :error, ex
      raise
    ensure
      record_timer process_name(process_file), start_time, Time.now
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

  def validate_file_in_arguments(args)
    exit_if_no_file_specified args
    exit_if_no_such_file_exists args.first
    args.first
  end



  def exit_if_no_file_specified(args)
    if args.empty?
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



  def process_name(file_name)
    File.basename(file_name, File.extname(file_name))
  end

end
