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
        (properties - Mongoid.destructive_fields).each do |prop|
          if mapping[prop]
            field prop, :type => String, :as => mapping[prop]
          else
            field prop, :type => String
          end
          attr_accessible prop
        end
      end
    end

    def to_rdf(url)
      RDF::Graph.new do |graph|
        vocabularies.each do |v|
          v.properties.each do |prop|
            next unless self[prop]
            graph << [url, v.send(prop), self[prop]]
          end
        end
      end
    end
  end
end

