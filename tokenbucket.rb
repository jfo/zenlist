class TokenBucket
    attr_reader :interval

    def initialize(r:, b:)
        @interval = 1.0/r; @limit = b
        @bucket = @limit
        begin_ticking
    end

    def accept_request?
        !!(@bucket = (@bucket - 1).clamp(0, @limit) if @bucket > 0)
    end

    private

    def begin_ticking
        # A single thread for a single TokenBucket works just fine, here... It
        # also works if you instantiate multiple buckets at different rates for
        # different endpoints, for example, but I can see making a helper class
        # like TokenBucketManager that registers Buckets and increments all of
        # them on schedule in a master thread.
        Thread.new do
            loop do
                # `sleep` is a rudimentary way to accomplish this but we're
                # using up the whole thread anyway.
                sleep @interval
                @bucket = (@bucket + 1).clamp(0, @limit)
            end
        end
    end
end
