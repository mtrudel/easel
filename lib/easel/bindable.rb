module Easel
  module Bindable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def bind_to(vocab, opts = {})
        opts ||= {}
        @vocab = vocab
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
      raise "Not done yet"
      @vocab.properties.each do |prop|
        # create the implied triple
      end
    end
  end
end

