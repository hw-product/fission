module Fission
  module Mixin
    module ConvertToClassName

      def convert_to_class_name(str)
        str = str.dup
        str.gsub!(/[^A-Za-z0-9_]/,'_')
        rname = nil
        regexp = %r{^(.+?)(_(.+))?$}

        mn = str.match(regexp)
        if mn
          rname = mn[1].capitalize

          while mn && mn[3]
            mn = mn[3].match(regexp)
            rname << mn[1].capitalize if mn
          end
        end

        rname
      end

      def convert_to_snake_case(str, namespace=nil)
        str = str.dup
        str.sub!(/^#{namespace}(\:\:)?/, '') if namespace
        str.gsub!(/[A-Z]/) {|s| "_" + s}
        str.downcase!
        str.sub!(/^\_/, "")
        str
      end

      def snake_case_basename(str)
        with_namespace = convert_to_snake_case(str)
        with_namespace.split("::").last.sub(/^_/, '')
      end

    end
  end
end
