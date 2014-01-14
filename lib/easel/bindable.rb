require 'active_support'
require 'active_support/core_ext'

module Easel
  module Bindable
    extend ActiveSupport::Concern

    included do
      class_attribute :vocabularies
      self.vocabularies = Set.new
    end

    module ClassMethods
      def bind_to(vocab, opts = {})
        vocabularies << vocab
        properties = vocab.properties.dup
        opts[:only] = [opts[:only]] unless opts[:only].nil? || opts[:only].is_a?(Enumerable)
        properties &= opts[:only] if opts[:only]
        properties.each { |property| yield property } if block_given?
      end
    end

    def to_rdf(url)
      properties = self.serializable_hash
      RDF::Graph.new do |graph|
        vocabularies.each do |v|
          v.properties.each do |prop|
            next unless properties[prop]
            if properties[prop].kind_of? Enumerable
              properties[prop].each { |p| graph << [url, v.send(prop), p] }
            else
              graph << [url, v.send(prop), properties[prop]]
            end
          end
        end
      end
    end
  end
end

