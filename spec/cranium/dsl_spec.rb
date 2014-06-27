require_relative '../spec_helper'

describe Cranium::DSL do

  let(:dsl_object) { Object.new.tap { |object| object.extend Cranium::DSL } }

  describe "#database" do
    it "should register a database connection in the application" do
      block = lambda {}

      Cranium::Database.should_receive(:register_database) do |arg, &blk|
        expect(arg).to eq :name
        expect(blk).to be block
      end

      dsl_object.database(:name, &block)
    end
  end


  describe "#source" do
    it "should register a source in the application" do
      Cranium.application.should_receive(:register_source).with(:name)

      dsl_object.source(:name)
    end
  end


  describe "#extract" do
    it "should create an extract definition and execute it" do
      extract_definition = double "ExtractDefinition"
      block = lambda {}

      Cranium::DSL::ExtractDefinition.stub(:new).with(:contacts).and_return(extract_definition)
      expect(extract_definition).to receive(:instance_eval) { |&blk| expect(blk).to be block }

      extractor = double "DataExtractor"
      Cranium::Extract::DataExtractor.stub new: extractor
      extractor.should_receive(:execute).with(extract_definition)

      dsl_object.extract :contacts, &block
    end
  end


  describe "#deduplicate" do
    it "should call transform with correct source and target arguments" do
      dsl_object.should_receive(:transform).with(:sales_items => :products)
      dsl_object.deduplicate :sales_items, into: :products, by: [:item]
    end
  end


  describe "#import" do
    it "should create an import definition and execute it" do
      import_definition = double "ImportDefinition"
      block = lambda {}

      Cranium::DSL::ImportDefinition.stub(:new).with(:contacts).and_return(import_definition)
      expect(import_definition).to receive(:instance_eval) { |&blk| expect(blk).to be block }

      importer = double "DataImporter"
      Cranium::DataImporter.stub new: importer
      importer.should_receive(:import).with(import_definition)

      dsl_object.import :contacts, &block
    end
  end


  describe "#archive" do
    it "should archive files for the specified sources" do
      Cranium.application.stub sources: {first_source: double(files: ["file1", "file2"]),
                                         second_source: double(files: ["file3"]),
                                         third_source: double(files: ["file4"])}

      Cranium::Archiver.should_receive(:archive).with "file1", "file2"
      Cranium::Archiver.should_receive(:archive).with "file3"

      dsl_object.archive :first_source, :second_source
    end
  end


  describe "#remove" do
    it "should remove files for the specified sources" do
      Cranium.application.stub sources: {first_source: double(files: ["file1", "file2"]),
                                         second_source: double(files: ["file3"]),
                                         third_source: double(files: ["file4"])}

      Cranium::Archiver.should_receive(:remove).with "file1", "file2"
      Cranium::Archiver.should_receive(:remove).with "file3"

      dsl_object.remove :first_source, :second_source
    end
  end


  describe "#sequence" do
    it "should return a sequence with the specified name" do
      result = dsl_object.sequence "test_sequence"

      result.should be_a Cranium::Transformation::Sequence
      result.name.should == "test_sequence"
    end
  end


  describe "#after" do
    it "should register a new after hook for the application" do
      block = -> {}

      expect(Cranium.application).to receive(:register_hook).with(:after) { |&blk| expect(blk).to be block }

      dsl_object.after &block
    end
  end
end
