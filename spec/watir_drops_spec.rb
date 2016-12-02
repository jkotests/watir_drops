require 'spec_helper'

describe WatirDrops do

  it 'navigates to a simple url' do
    test_page = TestPage.visit
    expect(test_page.title).to eql 'Watir-WebDriver Demo'
  end

  it 'navigates to a dynamic url' do
    class TestPage2 < WatirDrops::PageObject
      page_url { |val| "http://bit.ly/#{val}" }
    end

    TestPage2.visit('watir-webdriver-demo')
    expect(@browser.title).to eql 'Watir-WebDriver Demo'
  end

  it 'raises Exception if wrong number of arguments used for page_url' do
    expect { TestPage.visit(:foo) }.to raise_error ArgumentError, "#page_url expects 0 arguments, but received 1"
  end

  it 'enters text into a textfield based on value it is set equal to' do
    TestPage.visit.name = 'Roger'
    expect(TestPage.use.name.value).to be == 'Roger'
  end

  it 'selects value from dropdown based on value it is set equal to' do
    TestPage.visit.language = 'Ruby'
    expect(TestPage.use.language.value).to be == 'Ruby'
  end

  it 'selects radio button based being set equal to a true value' do
    TestPage.visit.identity = true
    expect(TestPage.use.identity).to be_set
  end

  it 'selects checkbox based on being set equal to a true value' do
    TestPage.visit.version = true
    expect(TestPage.use.version).to be_set
  end

  it 'deselects checkbox based on being set equal to a true value' do
    TestPage.visit.version = true
    TestPage.use.version = false
    expect(TestPage.use.version).to_not be_set
  end

  it 'clicks button based on being set equal to a true value' do
    expect(TestPage.visit.error_message?).to be false
    TestPage.use.save_button = true
    expect(TestPage.use.error_message?).to be true
  end

  describe '#selector_string' do
    it 'throws custom error message in waits' do
      test_page = TestPage.visit

      message = /^timed out after 0\.5 seconds, waiting for true condition on #<TestPage url=\S+ title=/
      expect { test_page.wait_until(timeout: 0.5) { false } }.to raise_exception Watir::Wait::TimeoutError, message
    end
  end
end
