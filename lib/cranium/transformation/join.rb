require 'csv'

class Cranium::Transformation::Join

  attr_accessor :source_left, :source_right, :target, :match_fields



  def execute
    validate_parameters
    cache_commonly_used_values
    join_sources
  end



  private

  def validate_parameters
    raise "Missing left source for join transformation" if source_left.nil?
    raise "Missing right source for join transformation" if source_right.nil?
    raise "Missing target for join transformation" if target.nil?
    raise "Invalid match fields for join transformation" unless match_fields.nil? or match_fields.is_a? Hash
  end



  def cache_commonly_used_values
    @left_source_field_names = source_left.fields.keys
    @right_source_field_names = source_right.fields.keys
    @target_field_names = target.fields.keys
    @match_field_names = match_fields.keys
  end



  def join_sources
    build_join_table_from_right_source_files
    write_output_file
  end



  def build_join_table_from_right_source_files
    @join_table = {}
    source_right.files.each do |file|
      build_join_table_from_file file
    end
  end



  def build_join_table_from_file(file)
    line_number = 0
    CSV.foreach File.join(Cranium.configuration.upload_path, file), csv_read_options_for(source_right) do |row|
      next if 1 == (line_number += 1)

      record = Hash[@right_source_field_names.zip row]
      index_key = index_key_for record
      if @join_table.has_key? index_key
        @join_table[index_key] << record
      else
        @join_table[index_key] = [record]
      end
    end
  end



  def write_output_file
    CSV.open "#{Cranium.configuration.upload_path}/#{target.file}", "w:#{target.encoding}", csv_write_options_for(target) do |target_file|
      source_left.files.each do |file|
        process_left_source_file File.join(Cranium.configuration.upload_path, file), target_file
      end
    end
  end



  def process_left_source_file(input_file, output_file)
    line_number = 0
    CSV.foreach input_file, csv_read_options_for(source_left) do |row|
      next if 1 == (line_number += 1)

      record = Hash[@left_source_field_names.zip row]
      joined_records_for(record).each do |record_to_output|
        output_file << record_to_output.
          keep_if { |key| @target_field_names.include? key }.
          sort_by { |field, _| @target_field_names.index(field) }.
          map { |item| item[1] }
      end
    end
  end



  def joined_records_for(record)
    index_key = index_key_for record
    return [] unless @join_table.has_key? index_key
    @join_table[index_key].map { |matching_record| record.merge matching_record }
  end



  def index_key_for(record)
    record.select { |field, _| @match_field_names.include? field }.values
  end



  def csv_write_options_for(source_definition)
    {
      col_sep: source_definition.delimiter,
      quote_char: source_definition.quote,
      write_headers: true,
      headers: source_definition.fields.keys
    }
  end



  def csv_read_options_for(source_definition)
    {
      encoding: source_definition.encoding,
      col_sep: source_definition.delimiter,
      quote_char: source_definition.quote,
      return_headers: false
    }
  end

end
