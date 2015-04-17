module RQP2
  class Reporter
    class Dialect < WLang::Html

      def floating(buf, fn)
        value = evaluate(render(fn))
        buf << ((value.to_i == value) ? value.to_i : value.to_f).to_s
      end

      def classes(buf, fn)
        value   = evaluate(render(fn))
        classes = []
        classes << 'success' if value[:success]   == 1
        classes << 'failure' if value[:success]   == 0
        classes << 'ignored' if value[:accounted] == 0
        buf << classes.join(' ')
      end

      tag '@', :classes
      tag '.', :floating

    end # class Dialect
  end # class Reporter
end # module RQP2
