module Mongoid
  def self.destructive_fields
    []
  end

  module Document
    def self.included(base)
      base.extend(ClassMethods)
    end

    def vocab
      self.class.vocab
    end

    module ClassMethods
      attr_accessor :vocab

      def class_attribute(*)
      end

      def field(*args)
      end
    end
  end
end
