require 'spec_helper'

class TestDocument
  include Mongoid::Document
  include Easel::Bindable
end

describe Easel do
  subject do
    TestDocument
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
      vocab.properties.each do |p|
        subject.should_receive(:field).with(p, :type => String)
      end
      subject.bind_to(vocab)
    end

    it 'sending mapped fields should map them' do
      vocab = double(:properties => [:bacon])
      subject.should_receive(:field).with(:bacon, :type => String, :as => :delicious)
      subject.bind_to(vocab, :mapping => {:bacon => :delicious})
    end
  end

  describe 'to_rdf' do
    it 'should properly serilaize fields with values set' do
      vocab = double(:bacon => 'bacon', :ham => 'ham', :properties => [:bacon, :ham])
      subject.bind_to(vocab)
      o = subject.new
      o.should_receive(:[]).with(:bacon).twice.and_return('yummy')
      o.should_receive(:[]).with(:ham).and_return(nil)
      o.to_rdf.should == RDF::Graph.new do |graph|
        graph << ['#', 'bacon', 'yummy']
      end
    end
  end
end
