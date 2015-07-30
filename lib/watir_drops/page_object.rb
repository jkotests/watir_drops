module WatirDrops
  class PageObject

    class << self
      def page_url url
        define_method("goto") do
          browser.goto url
        end
      end

      def element(name, &block)
        define_method(name) do |*args|
          self.instance_exec(*args, &block)
        end
      end

    end

    attr_reader :browser

    def initialize(browser=nil)
      @browser = browser || WatirDrops::Session.instance.browser
    end

    def visit
      goto if self.respond_to? :goto
      self
    end

    def title
      browser.title
    end

  end
end
