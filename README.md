# RingArrays

[![Build Status](https://travis-ci.org/invenia/RingArrays.jl.svg?branch=develop)](https://travis-ci.org/invenia/RingArrays.jl) [![Build status](https://ci.appveyor.com/api/projects/status/u2yyj9necuobw7o7?svg=true)](https://ci.appveyor.com/project/samuel-massinon-invenia/ringarrays-jl) [![codecov.io](https://codecov.io/github/invenia/RingArrays.jl/coverage.svg?branch=develop)](https://codecov.io/github/invenia/RingArrays.jl?branch=develop)

RingArrays is a way to access a large dataset in incremental chucks to limit the amount of memory you need. You would use a RingArray when you are wanting to work with a massive dataset like an array.

The idea of the RingArray is that is should act like a sliding window on a massive array where the window is the only part of the array you currently care about. The sliding window will move at the pace you tell it too and will contain as much data as you want.

## Read Only

The RingArray is in a read only state. Trying to set a value will throw this error.

```julia
julia> ring[1] = 1
ERROR: indexing not defined for RingArrays.RingArray{Int64,1}
 in setindex! at ./abstractarray.jl:584
 in eval at ./boot.jl:265
```

## Usage

### Creating

Creating a RingArray only needs two values, both of which have default if you pass nothing.

```julia
ring = RingArray{Int, 3}(max_blocks=10, block_size=(10,10,10))
```

`max_block` will determine the most number of blocks the ring array can hold at any time.

`block_size` is the dimension size of the blocks. Each block must have the same size.

### Loading Blocks

RingArrays need there blocks to be loaded manually.

```julia
ring = RingArray{Int, 1}(max_blocks=5, block_size=(2,));
data = rand(Int64, ring.block_size);
load_block(ring, data);
display(ring)
data = rand(Int64, ring.block_size);
load_block(ring, data);
display(ring)
```

The output is,

```julia
5-element Array{AbstractArray{Int64,1},1}:
    [3786009800613455090,1882121033597674828]
 #undef                                      
 #undef                                      
 #undef                                      
 #undef                                      
5-element Array{AbstractArray{Int64,1},1}:
    [3786009800613455090,1882121033597674828] 
    [5361907351193705983,-3065296439201106247]
 #undef                                       
 #undef                                       
 #undef  
```
 
As you can see, the first display shows the first block loaded and the second display has the second block loaded too.

#### When loading lots of blocks

When you load more blocks than your RingArray can handle, it will begin to overwrite blocks, starting with the oldest.

```julia
ring = RingArray{Int, 1}(max_blocks=5, block_size=(2,));
for i in 1:4
    data = rand(Int64, ring.block_size);
    load_block(ring, data);
end
display(ring)
data = rand(Int64, ring.block_size);
load_block(ring, data);
display(ring)
data = rand(Int64, ring.block_size);
load_block(ring, data);
display(ring)
```

The output is,

```julia
5-element Array{AbstractArray{Int64,1},1}:
    [-5440869056910226509,1048203488083884946]
    [-5465828022146027573,2059040906267543744]
    [-4870925121561723238,7387116789012817270]
    [4235087124507848396,-1752098218431852782]
 #undef                                       
5-element Array{AbstractArray{Int64,1},1}:
 [-5440869056910226509,1048203488083884946] 
 [-5465828022146027573,2059040906267543744] 
 [-4870925121561723238,7387116789012817270] 
 [4235087124507848396,-1752098218431852782] 
 [-7708650732046828053,-5831043268171991420]
5-element Array{AbstractArray{Int64,1},1}:
 [-2394580099307101489,-5939753501841389193]
 [-5465828022146027573,2059040906267543744] 
 [-4870925121561723238,7387116789012817270] 
 [4235087124507848396,-1752098218431852782] 
 [-7708650732046828053,-5831043268171991420]
```

In the last display, we can see that the first row of values have been overwritten by the last load.

### Indexing

A RingArray can be accessed like the array it is 'sliding' over.

```julia
ring = RingArray{Int, 1}(max_blocks=4, block_size=(2,));
big_array = rand(Int, 100);
for i in 1:2:6
    load_block(ring, big_array[i:i+1]);
end
display(big_array[3])
display(ring[3])
for i in 7:2:12
    load_block(ring, big_array[i:i+1]);
end
display(big_array[8])
display(ring[8])
for i in 13:2:99
    load_block(ring, big_array[i:i+1]);
end
display(big_array[99])
display(ring[99])
```

The output is,

```julia
8138703126850143818
8138703126850143818
8704347357339359336
8704347357339359336
-1266028625934220613
-1266028625934220613
```

The output shows that the value we get from the RingArray is identical to the value we get from the 'big_array' we are looking at. The difference here is that the RingArray contains a max for `4 * 2 = 8` elements.

#### Range Indexing/Views

You can even use ranges to index into a RingArray, just like the 'big array'.

```julia
ring = RingArray{Int, 1}(max_blocks=4, block_size=(2,));
big_array = rand(Int, 100);
for i in 1:2:6
    load_block(ring, big_array[i:i+1]);
end
display(big_array[3:5])
display(ring[3:5])
for i in 7:2:99
    load_block(ring, big_array[i:i+1]);
end
display(big_array[93:100])
display(ring[93:100])
```

The output is,

```julia
3-element Array{Int64,1}:
  4888954431626633721
  -735569853239964777
 -2209041541700469789
3-element VirtualArrays.VirtualArray{Int64,1}:
  4888954431626633721
  -735569853239964777
 -2209041541700469789
8-element Array{Int64,1}:
 -8890283379952347965
  6099240732283067744
  1774549867342630701
 -7876908337657579670
  -655444807932357004
  6237563287695816159
  9143358181757180448
  5233312637010446397
8-element VirtualArrays.VirtualArray{Int64,1}:
 -8890283379952347965
  6099240732283067744
  1774549867342630701
 -7876908337657579670
  -655444807932357004
  6237563287695816159
  9143358181757180448
  5233312637010446397
```

All the values are the same. One thing to note is that the values returned are stored into a VirtualArray. It should act just like an array you would get from the 'big array' except will save on memory usage.

#### Where you can index

Since the RingArray is suppose to be treated like a sliding window over a larger array, our indexes must be within the window the RingArray currently has. In the example below, we output the ranges the RingArray has:

```julia
ring = RingArray{Int, 1}(max_blocks=4, block_size=(2,));
big_array = rand(Int, 100);
for i in 1:2:6
    load_block(ring, big_array[i:i+1]);
end
display(ring.range)
display(big_array[3])
display(ring[3])
for i in 7:2:12
    load_block(ring, big_array[i:i+1]);
end
display(ring.range)
display(big_array[8])
display(ring[8])
for i in 13:2:99
    load_block(ring, big_array[i:i+1]);
end
display(ring.range)
display(big_array[99])
display(ring[99])
```

The output is,

```julia
6-element UnitRange{Int64}:
 1,2,3,4,5,6
-5471073722013832555
-5471073722013832555
8-element UnitRange{Int64}:
 5,6,7,8,9,10,11,12
4049429779710085286
4049429779710085286
8-element UnitRange{Int64}:
 93,94,95,96,97,98,99,100
-7554212529707423474
-7554212529707423474
```

Anything between `ring.range` is a viable index into RingArray. Below is an example of indexing a value out of scope.

```juila
ring = RingArray{Int, 1}(max_blocks=4, block_size=(2,));
big_array = rand(Int, 100);
for i in 1:2:12
    load_block(ring, big_array[i:i+1]);
end
display(ring.range)
display(big_array[3])
display(ring[3])
```

The output is,

```julia
8-element UnitRange{Int64}:
 5,6,7,8,9,10,11,12
647156453227300720
ERROR: RingArrayBoundsError: Cannot index (3,), outside of range (5:12,)
 in checkbounds at /Users/samuelmassinon/.julia/v0.5/RingArrays/src/RingArrays.jl:83
 in getindex at /Users/samuelmassinon/.julia/v0.5/RingArrays/src/RingArrays.jl:98
 in eval at ./boot.jl:265
```

A custom error message will appear saying where you went out of bounds.

### Reference Counting

Views are a window into the RingArray and are not a copy of the original data. So if we were loading blocking into the RingArray and overwrote a view we had, that view would no longer point at what we want.

#### Preventing overwrite

To prevent this from happening, we implemented reference counting. This always us to make sure a block is no longer being used before we overwrite it. The example below shows what happens when we try to overwrite a block in use.

```
ring = RingArray{Int, 1}(max_blocks=4, block_size=(2,));
big_array = rand(Int, 100);
for i in 1:2:10
    load_block(ring, big_array[i:i+1]);
end
display(ring.range)
view = ring[5:7];
display(view)
display(ring.blocks)
for i in 11:2:20
    load_block(ring, big_array[i:i+1]);
end
display(view)
display(ring.blocks)
```

The output is,

```julia
8-element UnitRange{Int64}:
 3,4,5,6,7,8,9,10
3-element VirtualArrays.VirtualArray{Int64,1}:
 1544057856107072830
 8929073097273941100
 4699659618912958729
4-element Array{AbstractArray{Int64,1},1}:
 [-5031990884861863335,-3164449225297417624]
 [5365344782569642274,5184980088932498570]  
 [1544057856107072830,8929073097273941100]  
 [4699659618912958729,-3175526180812364101] 
ERROR: OverwriteError: Cannot overwrite block 3 since it has 1 views
 in load_block at /Users/samuelmassinon/.julia/v0.5/RingArrays/src/RingArrays.jl:119
 [inlined code] from ./range.jl:83
 in anonymous at ./range.jl:97
 in eval at ./boot.jl:265

 3-element VirtualArrays.VirtualArray{Int64,1}:
 1544057856107072830
 8929073097273941100
 4699659618912958729
4-element Array{AbstractArray{Int64,1},1}:
 [-5031990884861863335,-3164449225297417624]
 [6934442229844147992,1829732299464057830]  
 [1544057856107072830,8929073097273941100]  
 [4699659618912958729,-3175526180812364101]
```

The output shows that the 2nd block was overwritten, but when we tried to overwrite the 3rd block, RingArray checked and saw that it still had a view and threw an error.

#### Reference counting is manage by RingArray

You do not need to keep track of the reference counting yourself, RingArray will manage them. When getting a view, it will increment the count, and when that view goes out of scope, it will decrement it garbage collection or when you need to overwrite a block.

Here is an example of being able to overwrite a block after we get rid of the view.

```julia
ring = RingArray{Int, 1}(max_blocks=4, block_size=(2,));
big_array = rand(Int, 100);
for i in 1:2:10
    load_block(ring, big_array[i:i+1]);
end
display(ring.range)
view = ring[5:7];
display(view)
display(ring.blocks)
for i in 11:2:20
    load_block(ring, big_array[i:i+1]);
end
display(ring.range)
display(view)
display(ring.blocks)
view = 1; # the view no longer exists
for i in 13:2:20
    load_block(ring, big_array[i:i+1]);
end
display(ring.range)
display(view)
display(ring.blocks)
```

The output is,

```julia
8-element UnitRange{Int64}:
 3,4,5,6,7,8,9,10
3-element VirtualArrays.VirtualArray{Int64,1}:
 5911735777477926249
 3910434893574962823
 -906348638428454513
4-element Array{AbstractArray{Int64,1},1}:
 [-625772552758151126,743620623558767253]  
 [-9012475836041925679,8620617579832117383]
 [5911735777477926249,3910434893574962823] 
 [-906348638428454513,2603597537533504413] 
ERROR: OverwriteError: Cannot overwrite block 3 since it has 1 views
 in load_block at /Users/samuelmassinon/.julia/v0.5/RingArrays/src/RingArrays.jl:119
 [inlined code] from ./range.jl:83
 in anonymous at ./range.jl:97
 in eval at ./boot.jl:265

 8-element UnitRange{Int64}:
 5,6,7,8,9,10,11,12
3-element VirtualArrays.VirtualArray{Int64,1}:
 5911735777477926249
 3910434893574962823
 -906348638428454513
4-element Array{AbstractArray{Int64,1},1}:
 [-625772552758151126,743620623558767253] 
 [2405481536158146032,4216339971683807994]
 [5911735777477926249,3910434893574962823]
 [-906348638428454513,2603597537533504413]
8-element UnitRange{Int64}:
 13,14,15,16,17,18,19,20
1
4-element Array{AbstractArray{Int64,1},1}:
 [-4896354921357038745,-63704711846758516] 
 [8336018676551718190,9077386792586977037] 
 [-970205719865134290,-8463847478386580504]
 [1002526877401869676,1037177028879382219] 
```

The output shows that after we set `view = 1`, the block we want to overwrite no longer has any views into it and can no overwrite it.

### Expansions

The RingArray expects that the blocks stack on the first dimensions, so that the RingArray will expanded along the first dimension.

## Memory Usage

It is rather difficult to show how little memory a RingArray will take in comparison to its array counterpart. What I was able to show is how much memory a RingArray has in comparison of the array it is sliding along.

```julia
ring = RingArray{Int, 3}(max_blocks=10, block_size=(100,100,100));
big_array = rand(Int, 100000, 100, 100);
for i in 1:100:10000
    load_block(ring, big_array[i:i+99,1:end,1:end]);
end
whos()
for i in 10001:100:100000
    load_block(ring, big_array[i:i+99,1:end,1:end]);
end
whos()
```

The output is, (only showing what's important)

```
.
.
.
                     big_array 7812500 KB     100000x100x100 Array{Int64,3}
                          ring  78125 KB     1000x100x100 RingArrays.RingArray{Int64,3}
.
.
.
                     big_array 7812500 KB     100000x100x100 Array{Int64,3}
                          ring  78125 KB     1000x100x100 RingArrays.RingArray{Int64,3}
.
.
.
```

From the output, we see that in both cases, the RingArray keeps a constant size of `78125 KB` which is much smaller than the 'big array' at `7812500 KB`.