module Mongoid
  def self.destructive_fields
    []
  end

  module Document
    def self.included(base)
      base.extend(ClassMethods)
    end

    def vocabularies
      self.class.vocabularies
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
