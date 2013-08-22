module Fission
  module Mixin
    module ConvertToClassName

      def convert_to_class_name(str)
        str = str.to_s.gsub(/[^A-Za-z0-9_]/,'_').split('_').map(&:capitalize).join
      end

      def convert_to_snake_case(str, namespace=nil)
        str = str.to_s.sub(/^#{Regexp.escape(namespace)}(::)?/, '') if namespace
        str.to_s.split(/([A-Z][^A-Z]+)/).find_all do |sub_str|
          !sub_str.empty?
        end.join('_').downcase
      end

      def snake_case_basename(str)
        convert_to_snake_case.split('::').last
      end

    end
  end
end
