require 'spec_helper'

describe Easel do
  subject do
    Class.new(Object) do
      include Easel::Bindable
      include Mongoid::Document
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
      vocab.properties.each do |p|
        subject.should_receive(:field).with(p, :type => String)
      end
      subject.bind_to(vocab)
    end

    it 'should properly handle multiple calls to multiple vocabularies' do
      vocab1 = double(:properties => [:bacon, :ham, :sausage])
      vocab1.properties.each do |p|
        subject.should_receive(:field).with(p, :type => String)
      end
      vocab2 = double(:properties => [:beef, :meatballs, :hamburger])
      vocab2.properties.each do |p|
        subject.should_receive(:field).with(p, :type => String)
      end
      subject.bind_to(vocab1)
      subject.bind_to(vocab2)
    end

    it 'sending mapped fields should map them' do
      vocab = double(:properties => [:bacon])
      subject.should_receive(:field).with(:bacon, :type => String, :as => :delicious)
      subject.bind_to(vocab, :mapping => {:bacon => :delicious})
    end
  end

  describe 'to_rdf' do
    it 'should properly convert fields with values set' do
      vocab = double('vocab', :bacon => 'bacon', :ham => 'ham', :properties => [:bacon, :ham])
      subject.bind_to(vocab)
      o = subject.new
      o.should_receive(:[]).with(:bacon).twice.and_return('yummy')
      o.should_receive(:[]).with(:ham).and_return(nil)
      o.to_rdf.should == RDF::Graph.new do |graph|
        graph << ['#', 'bacon', 'yummy']
      end
    end

    it 'should properly convert all declared vocabularies' do
      vocab1 = double('vocab 1', :bacon => 'bacon', :ham => 'ham', :properties => [:bacon, :ham])
      vocab2 = double('vocab 2', :beef => 'beef', :meatballs => 'meatballs', :properties => [:beef, :meatballs])
      subject.bind_to(vocab1)
      subject.bind_to(vocab2)
      o = subject.new
      o.should_receive(:[]).with(:bacon).twice.and_return('yummy')
      o.should_receive(:[]).with(:ham).and_return(nil)
      o.should_receive(:[]).with(:beef).twice.and_return('yucky')
      o.should_receive(:[]).with(:meatballs).and_return(nil)
      o.to_rdf.should == RDF::Graph.new do |graph|
        graph << ['#', 'bacon', 'yummy']
        graph << ['#', 'beef', 'yucky']
      end
    end
  end
end
