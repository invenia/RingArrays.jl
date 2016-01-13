facts("About creating RingArray") do
    context("bad curly braces") do
        @fact_throws MethodError test = RingArray{Any}()
    end
    context("without curly braces") do
        @fact_throws MethodError RingArray()
    end

    context("passing the size") do
        test = RingArray{Int, 1}(rand(1:1000))
    end
    context("passing nothing") do
        test = RingArray{Int, 1}()
    end
end