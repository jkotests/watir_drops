# require 'active_support/inflector'

module WatirDrops
  class PageObject
    include Watir::Waitable

    class << self

      attr_writer :element_list
      attr_writer :required_element_list


      def page_url(required: false)
        define_method("page_url") do |*args|
          @require_url = required
          yield(*args)
        end

        define_method("goto") do |*args|
          browser.goto page_url(*args)
        end
      end

      def page_title
        define_method("page_title") do |*args|
          @require_title = true
          yield(*args)
        end
      end

      def element_list
        @element_list ||= []
      end

      def required_element_list
        @required_element_list ||= []
      end

      def inherited(subclass)
        subclass.element_list = element_list.dup
        subclass.required_element_list = required_element_list.dup
      end

      def elements(name, &block)
        define_method(name) do |*args|
          self.instance_exec(*args, &block)
        end

        element_list << name.to_sym
      end

      def element(name, required: false, &block)
        define_method(name) do |*args|
          self.instance_exec(*args, &block)
        end

        define_method("#{name}=") do |val|
          watir_element = self.instance_exec &block
          case watir_element
          when Watir::Radio
            watir_element.set if val
          when Watir::CheckBox
            val ? watir_element.set : watir_element.clear
          when Watir::Select
            watir_element.select val
          when Watir::Button
            watir_element.click
          when Watir::TextField, Watir::TextArea
            watir_element.set val if val
          else
            watir_element.click if val
          end
        end
        element_list << name.to_sym
        required_element_list << name.to_sym if required
      end

      def visit(*args)
        new.tap do |page|
          page.goto(*args)
          raise Watir::Exception::Error if page.verify_page? && !page.on_page?
        end
      end


      def browser=(browser_input)
        @@browser = browser_input
      end

      def browser
        @@browser
      end

    end

    attr_reader :browser

    def initialize(browser_input = @@browser)
      @browser = browser_input
    end

    def fill_form(model)
      intersect = case model
                  when OpenStruct
                    self.class.element_list & model.to_h.keys
                  when Hash
                    self.class.element_list & model.keys
                  else
                    self.class.element_list & model.keys.select { |el| !model.send(el).nil? }
                  end
      intersect.each do |val|
        self.send("#{val}=", model[val])
      end
    end

    def inspect
      '#<%s url=%s title=%s>' % [self.class, url.inspect, title.inspect]
    end

    alias selector_string inspect

    def verify_page?
      page_url if respond_to? :page_url
      page_title if respond_to? :page_title
      @require_url || @require_title || !self.class.required_element_list.empty?
    end

    def on_page?
      raise Selenium::WebDriver::Error::WebDriverError, "No values present to determine if on desired page" unless verify_page?
      @browser.wait_until do |browser|
        !@require_url || page_url.gsub("#{URI.parse(page_url).scheme}://", '') == browser.url.gsub("#{URI.parse(browser.url).scheme}://", '')
      end

      @browser.wait_until { |browser| !@require_title || browser.title == page_title }

      if self.class.required_element_list.any?
        Watir::Wait.until { self.class.required_element_list.all? { |e| send(e).present? } }
      end

      true
    rescue Watir::Wait::TimeoutError
      false
    end


    def method_missing(method, *args, &block)
      if @browser.respond_to?(method)
        @browser.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, _include_all = false)
      @browser.respond_to?(method) || super
    end
  end
end
