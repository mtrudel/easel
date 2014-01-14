require 'spec_helper'

describe Easel do
  subject do
    Class.new(OpenStruct) do
      include Easel::Bindable
      include ActiveModel::Serialization

      # The simplest active model implementation for our needs
      attr_accessor :attributes
      def initialize(attributes = {})
        @attributes = attributes
        metaclass = class << self; self; end
        attributes.each do |key, value|
          metaclass.send :attr_accessor, key
          self.send "#{key}=", value
        end
      end
    end
  end

  describe 'Mixin methods' do
    it 'should add bind_to method to the extended class' do
      subject.should respond_to(:bind_to)
    end

    it 'should add to_rdf method to instances of the extended class' do
      subject.new.should respond_to(:to_rdf)
    end
  end

  describe 'bind_to' do
    it 'basic usage should create field definitions for each vocabulary entry' do
      vocab = double(:properties => [:bacon, :ham, :sausage])
      received = []
      subject.bind_to(vocab) do |property|
        received << property
      end
      received.should == vocab.properties
    end

    it 'should only bind to :only fields specified by literal' do
      vocab = double(:properties => [:bacon, :ham])
      received = []
      subject.bind_to(vocab, :only => :bacon) do |property|
        received << property
      end
      received.should == [:bacon]
    end

    it 'should only bind to :only fields specified by array' do
      vocab = double(:properties => [:bacon, :ham])
      received = []
      subject.bind_to(vocab, :only => [:bacon]) do |property|
        received << property
      end
      received.should == [:bacon]
    end
  end

  describe 'to_rdf' do
    it 'should properly convert fields with values set' do
      uri = RDF::URI.new('http://example.com')
      bacon = RDF::URI.intern('bacon')
      ham = RDF::URI.intern('ham')
      vocab = double('vocab', :bacon => bacon, :ham => ham, :properties => [:bacon, :ham])
      subject.bind_to(vocab)
      o = subject.new(:bacon => :yummy)
      o.to_rdf(uri).should == RDF::Graph.new do |graph|
        graph << [uri, bacon, :yummy]
      end
    end

    it 'should properly convert fields which are enumerable' do
      uri = RDF::URI.new('http://example.com')
      bacon = RDF::URI.intern('bacon')
      ham = RDF::URI.intern('ham')
      vocab = double('vocab', :bacon => bacon, :ham => ham, :properties => [:bacon, :ham])
      subject.bind_to(vocab)
      o = subject.new(:bacon => [:crispy, :back, :peameal])
      o.to_rdf(uri).should == RDF::Graph.new do |graph|
        graph << [uri, bacon, :crispy]
        graph << [uri, bacon, :back]
        graph << [uri, bacon, :peameal]
      end
    end


    it 'should properly convert all declared vocabularies' do
      uri = RDF::URI.new('http://example.com')
      bacon = RDF::URI.intern('bacon')
      ham = RDF::URI.intern('ham')
      beef = RDF::URI.intern('beef')
      meatballs = RDF::URI.intern('meatballs')
      vocab1 = double('vocab 1', :bacon => bacon, :ham => ham, :properties => [:bacon, :ham])
      vocab2 = double('vocab 2', :beef => beef, :meatballs => meatballs, :properties => [:beef, :meatballs])
      subject.bind_to(vocab1)
      subject.bind_to(vocab2)
      o = subject.new(:bacon => :yummy, :beef => :yucky)
      o.to_rdf(uri).should == RDF::Graph.new do |graph|
        graph << [uri, bacon, :yummy]
        graph << [uri, beef, :yucky]
      end
    end
  end
end
