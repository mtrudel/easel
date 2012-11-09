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
        mapping = opts[:mapping] || {}
        type = opts[:type] || String
        properties = opts[:only] || vocab.properties
        (properties - Mongoid.destructive_fields).each do |prop|
          if mapping[prop]
            field prop, :type => type, :as => mapping[prop]
          else
            field prop, :type => type
          end
          attr_accessible prop unless opts[:accessible] === false
        end
      end
    end

    def to_rdf(url)
      RDF::Graph.new do |graph|
        vocabularies.each do |v|
          v.properties.each do |prop|
            next unless self[prop]
            if self[prop].kind_of? Enumerable
              self[prop].each { |p| graph << [url, v.send(prop), p] }
            else
              graph << [url, v.send(prop), self[prop]]
            end
          end
        end
      end
    end
  end
end

