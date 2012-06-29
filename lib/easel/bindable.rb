module Easel
  module Bindable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def bind_to(vocab, opts = {})
        opts ||= {}
        class_attribute :vocab
        self.vocab = vocab
        mapping = opts[:mapping] || {}
        (vocab.properties - Mongoid.destructive_fields).each do |prop|
          if mapping[prop]
            field prop, :type => String, :as => mapping[prop]
          else
            field prop, :type => String
          end
        end
      end
    end

    def to_rdf
      RDF::Graph.new do |graph|
        vocab.properties.each do |prop|
          next unless self[prop]
          graph << ['#', vocab.send(prop), self[prop]]
        end
      end
    end
  end
end

