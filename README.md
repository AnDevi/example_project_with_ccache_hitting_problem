# Problem with ccache hits after changing headers file's timestamps.

This is minimalistic project showing problem I found out. 

## Logs 

In paths below there are logs presenting my problem, generated before and after changing timestamp of header included in pch file:

- [successful hit logs before_changing hpp timestamp](project/logs/successful_hit_logs_before_changing_hpp_timestamp)
- [failure hit logs after changing hpp timestamp](project/logs/failure_hit_logs_after_changing_hpp_timestamp)

## How to reproduce this issue by yourself:

### Optional environment to build and reproduce this issue:

I prepared Dockerfile with `clang` and `qbs` to reproduce it.

To build docker use script (may take a while):

```sh
./docker_build.sh
```

To run docker's container with prepared image use:

```sh
./docker_run.sh
``` 

### Build and reproduce this issue:

To build go to dir `project`:

1) Run script:

```sh
./qbs_install.sh
```
First build so obviously we cache no hits, `ccache -s` output:

```
Summary:
  Hits:               0 /     2 (0.00 %)
    Direct:           0 /     2 (0.00 %)
    Preprocessed:     0 /     2 (0.00 %)
  Misses:             2
    Direct:           2
    Preprocessed:     2
Primary storage:
  Hits:               0 /     3 (0.00 %)
  Misses:             3
  Cache size (GB): 0.01 / 20.00 (0.04 %)
```
2) Delete previous build and build it again:

```sh
rm -r debug
./qbs_install.sh
```
Now we have hits, `ccache -s` output:

```
Summary:
  Hits:               2 /     4 (50.00 %)
    Direct:           2 /     4 (50.00 %)
    Preprocessed:     0 /     2 (0.00 %)
  Misses:             2
    Direct:           2
    Preprocessed:     2
Primary storage:
  Hits:               4 /     7 (57.14 %)
  Misses:             3
  Cache size (GB): 0.01 / 20.00 (0.04 %)
```
3) Here is where the problems begin, before next build change timestamp of headerfile and then build again:

```sh
touch common/common.hpp
rm -r debug
./qbs_install.sh
```
Now again we have no hits, `ccache -s` output:

```
Summary:
  Hits:               2 /     6 (33.33 %)
    Direct:           2 /     6 (33.33 %)
    Preprocessed:     0 /     4 (0.00 %)
  Misses:             4
    Direct:           4
    Preprocessed:     4
Primary storage:
  Hits:               6 /    10 (60.00 %)
  Misses:             4
  Cache size (GB): 0.01 / 20.00 (0.04 %)
``` 
Above are logs from that scenario which leads to undesirable cache misses. 



