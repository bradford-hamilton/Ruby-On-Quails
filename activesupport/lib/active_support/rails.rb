# frozen_string_literal: true

# This is private interface.
#
# Quails components cherry pick from Active Support as needed, but there are a
# few features that are used for sure in some way or another and it is not worth
# putting individual requires absolutely everywhere. Think blank? for example.
#
# This file is loaded by every Quails component except Active Support itself,
# but it does not belong to the Quails public interface. It is internal to
# Quails and can change anytime.

# Defines Object#blank? and Object#present?.
require_relative "core_ext/object/blank"

# Quails own autoload, eager_load, etc.
require_relative "dependencies/autoload"

# Support for ClassMethods and the included macro.
require_relative "concern"

# Defines Class#class_attribute.
require_relative "core_ext/class/attribute"

# Defines Module#delegate.
require_relative "core_ext/module/delegation"

# Defines ActiveSupport::Deprecation.
require_relative "deprecation"

# Defines Regexp#match?.
#
# This should be removed when Quails needs Ruby 2.4 or later, and the require
# added where other Regexp extensions are being used (easy to grep).
require_relative "core_ext/regexp"
