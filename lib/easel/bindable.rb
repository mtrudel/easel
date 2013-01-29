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
        properties = opts[:only] || vocab.properties
        opts.except! :mapping, :only

        (properties - Mongoid.destructive_fields).each do |prop|
          if mapping[prop]
            field prop, opts.merge(:as => mapping[prop])
          else
            field prop, opts
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

