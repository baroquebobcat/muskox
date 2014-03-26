require 'minitest/autorun'
require 'minitest/pride'
require 'muskox'


module  MiniTest::Assertions
    # override assert raises to use a kind of check while working out error hierarchy
    def assert_raises_kind_of *exp
    msg = "#{exp.pop}.\n" if String === exp.last

    begin
      yield
    rescue Minitest::Skip => e
      return e if exp.include? Minitest::Skip
      raise e
    rescue Exception => e
      expected = exp.any? { |ex| e.kind_of? ex }

      assert expected, proc {
        exception_details(e, "#{msg}#{mu_pp(exp)} exception expected, not")
      }

      return e
    end

    exp = exp.first if exp.size == 1

    flunk "#{msg}#{mu_pp(exp)} expected but nothing was raised."
  end
end