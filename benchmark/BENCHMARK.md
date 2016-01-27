## Benchmarking VirtualArray

Checking the performance of VirtualArray

### To run these BenchMarks

You need `Benchmark.jl`, which you can get [here](https://github.com/johnmyleswhite/Benchmark.jl).

In the `RingArray` directory, run `julia benchmark/benchmark.jl`. 

The results of that tests are stored in [benchmark_result](benchmark_result).

### Test Ran

The code I used to benchmark can be found [here](benchmark.jl).

### Results

The results of the test are [here](benchmark_result) and below.

```

################################################################################
# constructor
################################################################################

1x12 DataFrames.DataFrame
| Row | Category      | Benchmark                                                            | Iterations | TotalWall | AverageWall |
|-----|---------------|----------------------------------------------------------------------|------------|-----------|-------------|
| 1   | "constructor" | "RingArray{Int, 1}(max_blocks=m_b, block_size=b_s, data_length=d_l)" | 100        | 7.3092e-5 | 7.3092e-7   |

| Row | MaxWall  | MinWall | Timestamp             | JuliaHash                                  |
|-----|----------|---------|-----------------------|--------------------------------------------|
| 1   | 6.314e-6 | 5.0e-7  | "2016-01-27 13:54:24" | "d4749d2ca168413f3db659950a1855530b58686d" |

| Row | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|----------|----------|
| 1   | "19f30dfd5ac56369d496f1842f10367b3adbeda7" | "Darwin" | 4        |


################################################################################
# load_block
################################################################################

1x12 DataFrames.DataFrame
| Row | Category                | Benchmark    | Iterations | TotalWall | AverageWall | MaxWall   | MinWall    | Timestamp             |
|-----|-------------------------|--------------|------------|-----------|-------------|-----------|------------|-----------------------|
| 1   | "loading with no views" | "load_block" | 100        | 0.15648   | 0.0015648   | 0.0100991 | 0.00114638 | "2016-01-27 13:54:26" |

| Row | JuliaHash                                  | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|--------------------------------------------|----------|----------|
| 1   | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" | "Darwin" | 4        |

1x12 DataFrames.DataFrame
| Row | Category             | Benchmark    | Iterations | TotalWall | AverageWall | MaxWall | MinWall  | Timestamp             |
|-----|----------------------|--------------|------------|-----------|-------------|---------|----------|-----------------------|
| 1   | "loading with views" | "load_block" | 100        | 11.3351   | 0.113351    | 0.1391  | 0.108338 | "2016-01-27 13:54:37" |

| Row | JuliaHash                                  | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|--------------------------------------------|----------|----------|
| 1   | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" | "Darwin" | 4        |

2x4 DataFrames.DataFrame
| Row | Function             | Average   | Relative | Replications |
|-----|----------------------|-----------|----------|--------------|
| 1   | "loading_no_views"   | 0.0016353 | 1.0      | 100          |
| 2   | "loading_with_views" | 0.114491  | 70.0124  | 100          |


################################################################################
# size
################################################################################

1x12 DataFrames.DataFrame
| Row | Category          | Benchmark          | Iterations | TotalWall | AverageWall | MaxWall  | MinWall | Timestamp             |
|-----|-------------------|--------------------|------------|-----------|-------------|----------|---------|-----------------------|
| 1   | "size empty ring" | "size(empty_ring)" | 100        | 2.9823e-5 | 2.9823e-7   | 1.935e-6 | 2.72e-7 | "2016-01-27 13:54:50" |

| Row | JuliaHash                                  | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|--------------------------------------------|----------|----------|
| 1   | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" | "Darwin" | 4        |

1x12 DataFrames.DataFrame
| Row | Category         | Benchmark         | Iterations | TotalWall | AverageWall | MaxWall | MinWall | Timestamp             |
|-----|------------------|-------------------|------------|-----------|-------------|---------|---------|-----------------------|
| 1   | "size full ring" | "size(full_ring)" | 100        | 2.5203e-5 | 2.5203e-7   | 6.35e-7 | 2.43e-7 | "2016-01-27 13:54:50" |

| Row | JuliaHash                                  | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|--------------------------------------------|----------|----------|
| 1   | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" | "Darwin" | 4        |

1x12 DataFrames.DataFrame
| Row | Category        | Benchmark        | Iterations | TotalWall | AverageWall | MaxWall  | MinWall | Timestamp             |
|-----|-----------------|------------------|------------|-----------|-------------|----------|---------|-----------------------|
| 1   | "size end ring" | "size(end_ring)" | 100        | 2.8393e-5 | 2.8393e-7   | 1.592e-6 | 2.52e-7 | "2016-01-27 13:54:50" |

| Row | JuliaHash                                  | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|--------------------------------------------|----------|----------|
| 1   | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" | "Darwin" | 4        |

3x4 DataFrames.DataFrame
| Row | Function           | Average   | Relative | Replications |
|-----|--------------------|-----------|----------|--------------|
| 1   | "size_empty_bench" | 2.6043e-7 | 1.01762  | 100          |
| 2   | "size_full_bench"  | 2.5592e-7 | 1.0      | 100          |
| 3   | "size_end_bench"   | 2.8343e-7 | 1.10749  | 100          |


################################################################################
# checkbounds
################################################################################

1x12 DataFrames.DataFrame
| Row | Category                | Benchmark                                      | Iterations | TotalWall | AverageWall | MaxWall  |
|-----|-------------------------|------------------------------------------------|------------|-----------|-------------|----------|
| 1   | "checkbounds full ring" | "checkbounds(full_ring, full_ring.range.stop)" | 100        | 7.1455e-5 | 7.1455e-7   | 6.704e-6 |

| Row | MinWall | Timestamp             | JuliaHash                                  | CodeHash                                   |
|-----|---------|-----------------------|--------------------------------------------|--------------------------------------------|
| 1   | 5.65e-7 | "2016-01-27 13:54:50" | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" |

| Row | OS       | CPUCores |
|-----|----------|----------|
| 1   | "Darwin" | 4        |

1x12 DataFrames.DataFrame
| Row | Category               | Benchmark                                    | Iterations | TotalWall | AverageWall | MaxWall  |
|-----|------------------------|----------------------------------------------|------------|-----------|-------------|----------|
| 1   | "checkbounds end ring" | "checkbounds(end_ring, end_ring.range.stop)" | 100        | 6.2692e-5 | 6.2692e-7   | 1.763e-6 |

| Row | MinWall | Timestamp             | JuliaHash                                  | CodeHash                                   |
|-----|---------|-----------------------|--------------------------------------------|--------------------------------------------|
| 1   | 5.77e-7 | "2016-01-27 13:54:50" | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" |

| Row | OS       | CPUCores |
|-----|----------|----------|
| 1   | "Darwin" | 4        |

2x4 DataFrames.DataFrame
| Row | Function                 | Average   | Relative | Replications |
|-----|--------------------------|-----------|----------|--------------|
| 1   | "checkbounds_full_bench" | 5.9524e-7 | 1.00248  | 100          |
| 2   | "checkbounds_end_bench"  | 5.9377e-7 | 1.0      | 100          |


################################################################################
# getindex
################################################################################

1x12 DataFrames.DataFrame
| Row | Category                   | Benchmark                          | Iterations | TotalWall   | AverageWall | MaxWall   |
|-----|----------------------------|------------------------------------|------------|-------------|-------------|-----------|
| 1   | "getindex full start ring" | "full_ring[full_ring.range.start]" | 100        | 0.000409074 | 4.09074e-6  | 4.1367e-5 |

| Row | MinWall  | Timestamp             | JuliaHash                                  | CodeHash                                   |
|-----|----------|-----------------------|--------------------------------------------|--------------------------------------------|
| 1   | 3.005e-6 | "2016-01-27 13:54:50" | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" |

| Row | OS       | CPUCores |
|-----|----------|----------|
| 1   | "Darwin" | 4        |

1x12 DataFrames.DataFrame
| Row | Category                  | Benchmark                         | Iterations | TotalWall   | AverageWall | MaxWall   | MinWall  |
|-----|---------------------------|-----------------------------------|------------|-------------|-------------|-----------|----------|
| 1   | "getindex full stop ring" | "full_ring[full_ring.range.stop]" | 100        | 0.000474399 | 4.74399e-6  | 3.9133e-5 | 3.017e-6 |

| Row | Timestamp             | JuliaHash                                  | CodeHash                                   | OS       |
|-----|-----------------------|--------------------------------------------|--------------------------------------------|----------|
| 1   | "2016-01-27 13:54:50" | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" | "Darwin" |

| Row | CPUCores |
|-----|----------|
| 1   | 4        |

1x12 DataFrames.DataFrame
| Row | Category                  | Benchmark                        | Iterations | TotalWall   | AverageWall | MaxWall  | MinWall  |
|-----|---------------------------|----------------------------------|------------|-------------|-------------|----------|----------|
| 1   | "getindex end start ring" | "end_ring[end_ring.range.start]" | 100        | 0.000373005 | 3.73005e-6  | 9.838e-6 | 3.001e-6 |

| Row | Timestamp             | JuliaHash                                  | CodeHash                                   | OS       |
|-----|-----------------------|--------------------------------------------|--------------------------------------------|----------|
| 1   | "2016-01-27 13:54:50" | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" | "Darwin" |

| Row | CPUCores |
|-----|----------|
| 1   | 4        |

1x12 DataFrames.DataFrame
| Row | Category                 | Benchmark                       | Iterations | TotalWall   | AverageWall | MaxWall  | MinWall  |
|-----|--------------------------|---------------------------------|------------|-------------|-------------|----------|----------|
| 1   | "getindex end stop ring" | "end_ring[end_ring.range.stop]" | 100        | 0.000340461 | 3.40461e-6  | 6.787e-6 | 3.006e-6 |

| Row | Timestamp             | JuliaHash                                  | CodeHash                                   | OS       |
|-----|-----------------------|--------------------------------------------|--------------------------------------------|----------|
| 1   | "2016-01-27 13:54:50" | "d4749d2ca168413f3db659950a1855530b58686d" | "19f30dfd5ac56369d496f1842f10367b3adbeda7" | "Darwin" |

| Row | CPUCores |
|-----|----------|
| 1   | 4        |

4x4 DataFrames.DataFrame
| Row | Function                    | Average    | Relative | Replications |
|-----|-----------------------------|------------|----------|--------------|
| 1   | "getindex_full_start_bench" | 3.64201e-6 | 1.08802  | 100          |
| 2   | "getindex_full_stop_bench"  | 3.4142e-6  | 1.01996  | 100          |
| 3   | "getindex_end_start_bench"  | 3.37917e-6 | 1.0095   | 100          |
| 4   | "getindex_end_stop_bench"   | 3.34737e-6 | 1.0      | 100          |
```