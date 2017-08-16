require 'test/unit'
require_relative 'tokenbucket'

class TokenBucket_Test < Test::Unit::TestCase
    self.test_order = :defined

    def setup
        @bucket = TokenBucket.new(r: 100, b: 5)
    end

    def test_bucket_accepts_requests_immediately
        assert(@bucket.accept_request?)
    end

    def test_bucket_rejects_requests_on_overload
        1..10.times { @bucket.accept_request? }
        assert_false(@bucket.accept_request?)
    end

    def test_bucket_refills
        1..6.times { @bucket.accept_request? }
        assert_false(@bucket.accept_request?)
        sleep @bucket.interval + 0.01
        assert(@bucket.accept_request?)
    end
end
