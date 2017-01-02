#!/usr/bin/env ruby

require 'dmenu'
require 'test/unit'

class DmenuTest < Test::Unit::TestCase
    include Dmenu
    def test_1
        assert_equal(10, Dmenu::scrunch("012345678901234567890", 10).width)
    end
    def test_2
        assert(Dmenu::scrunch("患部で止まってすぐ溶ける　～ 狂気の優曇華院 (03:04)", 10).width <= 10)
    end
    def test_3
        assert_not_nil(Dmenu::dmenu(%w<a b c>))
    end
end
