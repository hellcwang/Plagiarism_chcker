# Plagiarism_chcker
Simple plagiarism checker using `sdiff`.

## Usage
| option | description |
|--------|-------------|
| `-h`   | show help message |
| `-e`   | specify the extension of file wnat to check. (default `c, h, cpp`) |
| `-d`   | Specify the difference ratio line of file, if the difference > DIFF_RATIO -> output. (default 90(%))|

```
./plagiarism_checker [-e file extension][-d DIFF_RARIO][target dir]
```

## Acknowledgement & Reference & Credict
[Jan Warchoł ( The original author )](https://stackoverflow.com/users/2058424/jan-warcho%c5%82)

[Original post](https://stackoverflow.com/questions/2722947/percentage-value-with-gnu-diff)
