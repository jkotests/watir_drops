require 'spec_helper'

class PageRequired < WatirDrops::PageObject
  page_url(required: true) { 'https://www.google.com/?gws_rd=ssl' }
end

class TitleRequired < WatirDrops::PageObject
  page_url { 'https://www.google.com/?gws_rd=ssl' }
  page_title { 'Google' }
end

class ElementsRequired < WatirDrops::PageObject
  page_url { 'https://www.google.com/?gws_rd=ssl' }
  element(:search, required: true) { browser.text_field(id: 'lst-ib') }
end

class NoneRequired < WatirDrops::PageObject
  page_url { 'https://www.example.com' }
end

module WatirDrops
  describe 'PageObject#on_page?' do
    context 'when url required' do
      it 'returns true on correct page after visit' do
        page_required = PageRequired.visit
        expect(page_required.on_page?).to eql true
      end

      it 'returns true on correct page without visit call' do
        @browser.goto 'https://www.google.com/?gws_rd=ssl'
        expect(PageRequired.new.on_page?).to eql true
      end

      it 'returns false on incorrect page' do
        NoneRequired.visit
        page_required = PageRequired.new
        expect(page_required.on_page?).to eql false
      end
    end

    context 'when title required' do
      it 'returns true on correct title' do
        title_required = TitleRequired.visit
        expect(title_required.on_page?).to eql true
      end

      it 'returns false on incorrect title' do
        NoneRequired.visit
        title_required = TitleRequired.new
        expect(title_required.on_page?).to eql false
      end
    end

    context 'when elements required' do
      it 'returns true on correct elements' do
        elements_required = ElementsRequired.visit
        expect(elements_required.on_page?).to eql true
      end

      it 'returns false on incorrect elements' do
        NoneRequired.visit
        elements_required = ElementsRequired.new
        expect(elements_required.on_page?).to eql false
      end
    end

    context 'when nothing is required' do
      it 'raises exception' do
        none_required = NoneRequired.visit
        expect { none_required.on_page? }.to raise_exception(Selenium::WebDriver::Error::WebDriverError)
      end
    end

  end
end
