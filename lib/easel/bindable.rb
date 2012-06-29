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
      @vocab.properties.each do |prop|
        raise "Not done yet"
        # create the implied triple
      end
    end
  end
end

