# frozen_string_literal: true

module Quails
  class Engine < Railtie
    class Railties
      include Enumerable
      attr_reader :_all

      def initialize
        @_all ||= ::Quails::Railtie.subclasses.map(&:instance) +
          ::Quails::Engine.subclasses.map(&:instance)
      end

      def each(*args, &block)
        _all.each(*args, &block)
      end

      def -(others)
        _all - others
      end
    end
  end
end
