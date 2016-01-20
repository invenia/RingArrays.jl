facts("About creating RingArray") do
    context("bad curly braces") do
        @fact_throws MethodError test = RingArray{Any}()
    end
    context("without curly braces") do
        @fact_throws MethodError RingArray()
    end

    context("passing a size") do
        s = rand(1:10)
        b_s = (10,)
        test = RingArray{Int, 1}(s)

        @fact isdefined(test.blocks, 1:s...) --> false
        @pending test.blocks --> Array{AbstractArray{Int64,1},1}()
        @fact test.max_blocks --> s
        @fact test.next_write --> 1
        @fact test.num_users --> zeros(Int, s)
        @fact test.block_size --> b_s
        @fact test.range --> 1:0
        @fact size(test) --> tuple(b_s[1]*s,)
    end
    context("passing nothing") do
        s = 10
        b_s = (10,)
        test = RingArray{Int, 1}()

        @pending test.blocks --> Array{AbstractArray{Int64,1},1}()
        @fact test.max_blocks --> s
        @fact test.next_write --> 1
        @fact test.num_users --> zeros(Int, s)
        @fact test.block_size --> b_s
        @fact test.range --> 1:0
        @fact size(test) --> tuple(b_s[1]*s,)
    end
    context("passing 0 for size") do
        s = 0
        b_s = (10,)
        test = RingArray{Int, 1}(s)

        @pending test.blocks --> Array{AbstractArray{Int64,1},1}()
        @fact test.max_blocks --> s
        @fact test.next_write --> 1
        @fact test.num_users --> zeros(Int, s)
        @fact test.block_size --> b_s
        @fact test.range --> 1:0
        @fact size(test) --> tuple(b_s[1]*s,)
    end
    context("passing a negative for size") do
        s = -1
        @fact_throws test = RingArray{Int, 1}(s)
    end
    context("having a multi dimensional array") do
        s = 10
        b_s = (10,10)
        test = RingArray{Int, 2}(s, b_s)

        @pending test.blocks --> Array{AbstractArray{Int64,2},1}()
        @fact test.max_blocks --> s
        @fact test.next_write --> 1
        @fact test.num_users --> zeros(Int, s)
        @fact test.block_size --> b_s
        @fact test.range --> 1:0
        @fact size(test) --> tuple(b_s[1]*s, b_s[2:end]...)
    end
end

facts("Getting values from RingArray") do
    context("Getting the first value") do
        s = rand(1:10)
        b_s = (rand(1:10),)
        test = RingArray{Int, 1}(s, b_s)

        for i in 1:s
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[1]) --> Int
        @fact test[1] --> test.blocks[1][1]
        @fact test[1] --> test[1]
        @fact test[] --> nothing
    end
    context("Getting the first value without loading") do
        s = rand(1:10)
        b_s = (rand(1:10),)
        test = RingArray{Int, 1}(s, b_s)

        @fact_throws BoundsError test[1]
    end
    context("Getting a value in the first block") do
        s = rand(1:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(s, b_s)
        index = rand(2:b_s[1])

        for i in 1:s
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[1][index]
        @fact test[index] --> test[index]
    end
    context("Getting a value in the second block after getting a value in the first block") do
        s = rand(2:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(s, b_s)
        index = b_s[1] + 1

        for i in 1:s
            load_block(test, rand(Int, test.block_size))
        end

        test[1] # Need to get a value in the first block first
        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[2][1]
        @fact test[index] --> test[index]
    end
    context("Getting a value in the second block first") do
        s = rand(2:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(s, b_s)
        index = b_s[1] + 1

        for i in 1:s
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[2][1]
        @fact test[index] --> test[index]
    end
    context("Getting a value in the second block first while only loading the first block") do
        s = rand(2:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(s, b_s)
        index = b_s[1] + 1

        for i in 1:1
            load_block(test, rand(Int, test.block_size))
        end

        @fact_throws BoundsError test[index]
    end
    context("Getting a value in any block first") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(s, b_s)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        index = index_in_block + (block_picked - 1) * b_s[1]

        for i in 1:s
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
    end

    context("Getting value from 2 d array") do
        s = rand(3:10)
        b_s = (rand(1:10),rand(1:10))
        block_picked = rand(3:s)
        index_in_block = (rand(1:b_s[1]), rand(1:b_s[2]))
        index = (index_in_block[1] + (block_picked - 1) * b_s[1], index_in_block[2])

        test = RingArray{Int, 2}(s, b_s)

        for i in 1:s
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[index...]) --> Int
        @fact test[index...] --> test.blocks[block_picked][index_in_block...]
        @fact test[index...] --> test[index...]
    end
end

facts("Getting values over the length (overflow) of the RingArray") do
    context("Getting the first value after overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = 1
        index_in_block = 1
        overflow = s * b_s[1]
        index = overflow + 1

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:index ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
    end
    context("Getting the first value after overflowing with only before overflow") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = 1
        index_in_block = 1
        overflow = s * b_s[1]
        index = overflow + 1

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:index ÷ b_s[1]
            load_block(test, rand(Int, test.block_size))
        end

        @fact_throws BoundsError test[index]
    end
    context("Getting any value after overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:index ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
    end
    context("Getting any value after any number of overflows") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow * num_overflows

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:index ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
    end
    context("Getting value from 2 d array after overflowing") do
        s = rand(3:10)
        b_s = (rand(1:10),rand(1:10))
        block_picked = rand(3:s)
        index_in_block = (rand(1:b_s[1]), rand(1:b_s[2]))
        overflow = s * b_s[1]
        index = (index_in_block[1] + (block_picked - 1) * b_s[1] + overflow, index_in_block[2])

        test = RingArray{Int, 2}(s, b_s)

        for i in 1:index[1] ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[index...]) --> Int
        @fact test[index...] --> test.blocks[block_picked][index_in_block...]
        @fact test[index...] --> test[index...]
    end
end

facts("Getting data views") do
    context("looking at a small portion of the first block") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = 1
        start = rand(1:b_l)
        last = rand(start:b_l)
        range = start:last

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:range.stop ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[range]) --> VirtualArrays.VirtualArray{Int64,1}
        @fact test[range] --> test.blocks[block_picked][range]
        @fact test[range] --> test[range]
    end
    context("looking at a small portion of the first block without loading") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = 1
        start = rand(1:b_l)
        last = rand(start:b_l)
        range = start:last

        test = RingArray{Int, 1}(s, b_s)

        @fact_throws BoundsError test[range]
    end
    context("looking at a the whole portion of the first block") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = 1
        start = 1
        last = b_l
        range = start:last

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:range.stop ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[range]) --> VirtualArrays.VirtualArray{Int64,1}
        @fact test[range] --> test.blocks[block_picked][range]
        @fact test[range] --> test[range]
    end
    context("looking at a small portion of any block") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s)
        start = rand(1:b_l)
        last = rand(start:b_l)
        range = start:last
        ring_range = range + (block_picked - 1) * b_l

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:ring_range.stop ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[ring_range]) --> VirtualArrays.VirtualArray{Int64,1}
        @fact test[ring_range] --> test.blocks[block_picked][range]
        @fact test[ring_range] --> test[ring_range]
    end
    context("looking at a small portion of two blocks") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last
        ring_range = range + (block_picked - 1) * b_l

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:ring_range.stop ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[ring_range]) --> VirtualArrays.VirtualArray{Int64,1}
        @fact test[ring_range] --> [test.blocks[block_picked][range.start:end]...,
                                    test.blocks[block_picked + 1][1:range.stop - b_l]...]
        @fact test[ring_range] --> test[ring_range]
    end
    context("looking at a portion of two blocks at overflow") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        ring_range = range + (block_picked - 1) * b_l

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:ring_range.stop ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[ring_range]) --> VirtualArrays.VirtualArray{Int64,1}
        @fact test[ring_range] --> [test.blocks[block_picked][range.start:end]...,
                                    test.blocks[block_picked + 1][1:range.stop - b_l]...]
        @fact test[ring_range] --> test[ring_range]
    end
    context("looking at a portion of two blocks at overflow of a 2d ring array") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_w = rand(1:10)
        b_s = (b_l,b_w)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = (start:last,1:b_w)
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        ring_range = (range[1] + (block_picked - 1) * b_l, 1:b_w)

        test = RingArray{Int, 2}(s, b_s)

        for i in 1:ring_range[1].stop ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact typeof(test[ring_range...]) --> VirtualArrays.VirtualArray{Int64,2}
        @fact test[ring_range...] --> [test.blocks[block_picked][range[1].start:end, range[2]];
                                    test.blocks[block_picked + 1][1:range[1].stop - b_l, range[2]]]
        @fact test[ring_range...] --> test[ring_range...]
    end
end

facts("Using checkbounds)") do
    context("checking bounds before overflow without overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        index = index_in_block + (block_picked - 1) * b_s[1]

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:index ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact checkbounds(test, index) --> true
        @fact checkbounds(test) --> true
    end
    context("checking bounds after overflow without overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:index ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact checkbounds(test, index) --> true
    end
    context("checking bounds after overflow with overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:index ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact checkbounds(test, index) --> true
    end
    context("checking bounds before overflow with overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]

        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:index ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact_throws BoundsError checkbounds(test, 1)
    end
    context("checking unit range bounds before overflow without overflowing") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:range.stop ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact checkbounds(test, range) --> true
    end
    context("checking unit range bounds after overflow without overflowing") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last
        overflow = s * b_s[1]
        ring_range = range + (block_picked - 1) * b_l + overflow

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:ring_range.stop ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact checkbounds(test, ring_range) --> true
    end
    context("checking unit range bounds after overflow with overflowing") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        ring_range = range + (block_picked - 1) * b_l + overflow

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:ring_range.stop ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact checkbounds(test, ring_range) --> true
    end
    context("checking unit range bounds before overflow with overflowing") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        ring_range = range + (block_picked - 1) * b_l + overflow

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:ring_range.stop ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact_throws BoundsError checkbounds(test, 1:overflow)
    end
end

facts("Using display") do
    context("trying display on a typical RingArray") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        index = index_in_block + (block_picked - 1) * b_s[1]

        test = RingArray{Int, 1}(s, b_s)

        @fact display(test) --> nothing
    end
end

facts("Using views") do
    context("having the RingArray overflow when no views in use") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:index ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact test[index] --> test.blocks[block_picked][index_in_block]
    end
    context("having the RingArray overflow when first block is in use") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(s, b_s)

        load_block(test, rand(Int, test.block_size))

        view = test[1:1]

        for i in 2:overflow ÷ b_s[1]
            @fact load_block(test, rand(Int, test.block_size)) --> nothing
        end

        @fact_throws OverwriteError load_block(test, rand(Int, test.block_size))
        @fact view --> test[1:1]
    end
    context("having the RingArray overflow to the first block when second block is in use") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(s, b_s)

        for i in 1:index ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        view = test[b_l + 1:b_l + 1]

        @fact test[index] --> test.blocks[1][1]
    end
    context("having a view that goes out of scope and run gc") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(s, b_s)

        load_block(test, rand(Int, test.block_size))

        let
            local view = test[1:1]
        end

        gc()

        for i in 2:index ÷ b_s[1] + 1
            @fact load_block(test, rand(Int, test.block_size)) --> nothing
        end

        @fact test[index] --> test.blocks[1][1]
    end
    context("having a view that goes out of scope don't run gc") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(s, b_s)

        load_block(test, rand(Int, test.block_size))

        let
            local view = test[1:1]
        end

        for i in 2:index ÷ b_s[1] + 1
            @fact load_block(test, rand(Int, test.block_size)) --> nothing
        end

        @fact test[index] --> test.blocks[1][1]
    end
    context("having many views that goes out of scope don't run gc") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(s, b_s)

        load_block(test, rand(Int, test.block_size))

        let
            for i in 1:rand(100:200)
                local view = test[1:1]
            end
        end

        for i in 2:index ÷ b_s[1] + 1
            @fact load_block(test, rand(Int, test.block_size)) --> nothing
        end

        @fact test[index] --> test.blocks[1][1]
    end
    context("having a view that stays and many views that goes out of scope don't run gc") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(s, b_s)

        load_block(test, rand(Int, test.block_size))

        view = test[1:1]
        let
            for i in 1:rand(100:200)
                local view = test[1:1]
            end
        end

        for i in 2:index ÷ b_s[1]
            @fact load_block(test, rand(Int, test.block_size)) --> nothing
        end

        @fact_throws OverwriteError load_block(test, rand(Int, test.block_size))
        @fact view --> test[1:1]
    end
    context("having the RingArray overflow to the first block when second block is in use") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(s, b_s)

        load_block(test, rand(Int, test.block_size))
        load_block(test, rand(Int, test.block_size))

        view = test[b_l + 1:b_l + 1]

        for i in 3:index ÷ b_s[1] + 1
            load_block(test, rand(Int, test.block_size))
        end

        @fact test[index] --> test.blocks[1][1]
    end
end