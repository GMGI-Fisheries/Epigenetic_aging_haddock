# Pico Methyl-Seq Library Prep Kit Sample Processing 

Processing 140 Haddock fish fin clips from these extractions: https://github.com/emmastrand/Epigenetic_aging/blob/main/protocols%20and%20lab%20work/02-DNA_Extractions.md

Protocol from zymo: https://files.zymoresearch.com/protocols/_d5455_d5456_picomethylseq.pdf  
Protocol in house: https://github.com/emmastrand/GMGI_Notebook/blob/main/posts/2023-08-24%20Zymo%20Pico%20Methyl%20Seq%20Kit%20Protocol.md 

## Reagent prep

Spike-in sample: We're using E. coli Non-Methylated Genomic DNA from Zymo at 5 ug/20 uL concentration. For each sample, use 0.5% of E. coli DNA (e.g., 10 ng DNA input + 0.5 ng E. coli sample). 5 ug/20 uL = 0.25 ug/uL = 250 ng/uL.  
- Dilution calculator: https://physiologyweb.com/calculators/dilution_calculator_mass_per_volume.html 

Original stock: 0.25 ug/uL = 250 ng/uL  
Dilution 1: 1.6 uL of 0.25 ug/uL stock + 38.4 uL of AE buffer (10 mM Tris-HCl, 0.1 mM EDTA, pH 9.0) = 40 uL of 10 ng/uL  
Dilution 2: 2 uL of 10 ng/uL Dilution 1 + 38 uL of AE buffer (10 mM Tris-HCl, 0.1 mM EDTA, pH 9.0) = 40 uL of 0.5 ng/uL  

2023-09-08: *Dilutions made with AE buffer instead of the TE buffer (10 mM Tris-HCl, 1 mM EDTA, pH 9.0) that the E.coli is stored in. This is because we had plenty of AE from our Qiagen kit and they are very similar. Both are used as solutions for DNA elutions so I thought the E. coli DNA would be fine in AE buffer. AE buffer is used as input buffer to Pico Kit as well.* 

I'll take 1 uL of Dilution 2 for 0.5 ng input. Vortex these really well while making to ensure concentrations are as accurate as possible.  

## DNA prep 

5 ng/uL dilutions : 

**Plate 1** 

|   | 1       | 2       | 3       | 4       | 5       | 6       | 7       | 8       | 9       | 10      | 11      | 12      |
|---|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| A | Mae-263 | Mae-295 | Mae-327 | Mae-352 | Mae-396 | Mae-424 | Mae-454 | Mae-495 | Mae-520 | Mae-275 | Mae-303 | Mae-340 |
| B | Mae-266 | Mae-298 | Mae-329 | Mae-356 | Mae-399 | Mae-428 | Mae-464 | Mae-496 | Mae-524 | Mae-282 | Mae-304 | Mae-346 |
| C | Mae-274 | Mae-302 | Mae-330 | Mae-368 | Mae-403 | Mae-432 | Mae-468 | Mae-499 | Mae-525 | Mae-284 | Mae-324 | Mae-348 |
| D | Mae-278 | Mae-305 | Mae-338 | Mae-371 | Mae-405 | Mae-436 | Mae-470 | Mae-501 | Mae-533 | Mae-286 | Mae-325 | Mae-351 |
| E | Mae-281 | Mae-310 | Mae-342 | Mae-378 | Mae-410 | Mae-440 | Mae-475 | Mae-502 | Mae-535 | Mae-288 | Mae-331 | Mae-355 |
| F | Mae-285 | Mae-311 | Mae-343 | Mae-379 | Mae-414 | Mae-441 | Mae-477 | Mae-509 | Mae-537 | Mae-292 | Mae-332 | Mae-358 |
| G | Mae-293 | Mae-317 | Mae-344 | Mae-384 | Mae-421 | Mae-444 | Mae-481 | Mae-512 | Mae-265 | Mae-299 | Mae-334 | Mae-363 |
| H | Mae-294 | Mae-322 | Mae-350 | Mae-390 | Mae-422 | Mae-449 | Mae-488 | Mae-519 | Mae-271 | Mae-300 | Mae-337 | Mae-364 |

**Plate 2** 

|   | 1       | 2       | 3       | 4       | 5       | 6       | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---------|---------|---------|---------|---------|---------|---|---|---|----|----|----|
| A | Mae-366 | Mae-407 | Mae-438 | Mae-460 | Mae-500 | Mae-523 |   |   |   |    |    |    |
| B | Mae-374 | Mae-409 | Mae-443 | Mae-466 | Mae-504 | Mae-530 |   |   |   |    |    |    |
| C | Mae-377 | Mae-412 | Mae-447 | Mae-472 | Mae-508 | Mae-534 |   |   |   |    |    |    |
| D | Mae-381 | Mae-418 | Mae-450 | Mae-473 | Mae-510 | Mae-536 |   |   |   |    |    |    |
| E | Mae-386 | Mae-423 | Mae-451 | Mae-479 | Mae-511 |         |   |   |   |    |    |    |
| F | Mae-394 | Mae-426 | Mae-456 | Mae-482 | Mae-517 |         |   |   |   |    |    |    |
| G | Mae-398 | Mae-431 | Mae-458 | Mae-486 | Mae-518 |         |   |   |   |    |    |    |
| H | Mae-404 | Mae-435 | Mae-459 | Mae-494 | Mae-522 |         |   |   |   |    |    |    |

First five sample diluted on 20230912 and the rest on 20230918. 

| GMGI_ID | AgeRounded | Length | Sex | Length Bin | Final Ext ID | Qubit (ng/uL) | 5ng/uL Dilution: DNA (uL) | 5ng/uL Dilution: Tris (uL) AE   Buffer |
|---------|------------|--------|-----|------------|--------------|---------------|---------------------------|----------------------------------------|
| Mae-263 | 0.65       | 20.5   | M   | 20-25      | 1            | 31.8          | 6.29                      | 13.71                                  |
| Mae-266 | 0.65       | 16.5   | F   | 15-20      | 39           | 33.9          | 5.90                      | 14.10                                  |
| Mae-274 | 6.65       | 51.5   | F   | 50-55      | 87           | 20.8          | 9.62                      | 10.38                                  |
| Mae-278 | 3.65       | 51.5   | F   | 50-55      | 88           | 40.4          | 4.95                      | 15.05                                  |
| Mae-281 | 2.65       | 40.5   | M   | 40-45      | 17           | 27.3          | 7.33                      | 12.67                                  |
| Mae-285 | 0.65       | 16.5   | M   | 15-20      | 41           | 20.8          | 9.62                      | 10.38                                  |
| Mae-293 | 2.65       | 43     | F   | 40-45      | 92           | 20            | 10.00                     | 10.00                                  |
| Mae-294 | 9.65       | 51     | F   | 50-55      | 93           | 47.6          | 4.20                      | 15.80                                  |
| Mae-295 | 5.65       | 47.5   | F   | 45-50      | 18           | 36            | 5.56                      | 14.44                                  |
| Mae-298 | 1.65       | 27     | M   | 25-30      | 94           | 22.6          | 8.85                      | 11.15                                  |
| Mae-302 | 4.65       | 51.5   | F   | 50-55      | 43           | 42.8          | 4.67                      | 15.33                                  |
| Mae-305 | 9.65       | 54     | M   | 50-55      | 97           | 17.4          | 11.49                     | 8.51                                   |
| Mae-310 | 0.65       | 19     | M   | 15-20      | 4            | 23.3          | 8.58                      | 11.42                                  |
| Mae-311 | 1.65       | 28     | M   | 25-30      | 98           | 27            | 7.41                      | 12.59                                  |
| Mae-317 | 6.65       | 50     | M   | 45-50      | 44           | 84.3          | 2.37                      | 17.63                                  |
| Mae-322 | 7.65       | 44     | M   | 40-45      | 142          | 36.6          | 5.46                      | 14.54                                  |
| Mae-327 | 6.65       | 53     | F   | 50-55      | 20           | 48            | 4.17                      | 15.83                                  |
| Mae-329 | 4.65       | 54     | F   | 50-55      | 21           | 53.4          | 3.75                      | 16.25                                  |
| Mae-330 | 3.65       | 51     | F   | 50-55      | 143          | 16.5          | 12.12                     | 7.88                                   |
| Mae-338 | 4.65       | 51.5   | F   | 50-55      | 6            | 39.6          | 5.05                      | 14.95                                  |
| Mae-342 | 9.65       | 46     | F   | 45-50      | 26           | 11.6          | 17.24                     | 2.76                                   |
| Mae-343 | 2.65       | 34     | M   | 30-35      | 102          | 30.6          | 6.54                      | 13.46                                  |
| Mae-344 | 7.65       | 61     | M   | 60-65      | 46           | 29.9          | 6.69                      | 13.31                                  |
| Mae-350 | 6.65       | 47.5   | M   | 45-50      | 27           | 52.8          | 3.79                      | 16.21                                  |
| Mae-352 | 2.65       | 38     | M   | 35-40      | 104          | 17.1          | 11.70                     | 8.30                                   |
| Mae-356 | 1.65       | 28.5   | F   | 25-30      | 30           | 26.4          | 7.58                      | 12.42                                  |
| Mae-368 | 2.65       | 42.5   | M   | 40-45      | 107          | 46.4          | 4.31                      | 15.69                                  |
| Mae-371 | 1.65       | 30.5   | F   | 30-35      | 31           | 28.2          | 7.09                      | 12.91                                  |
| Mae-378 | 1.65       | 22.5   | M   | 20-25      | 48           | 90.8          | 2.20                      | 17.80                                  |
| Mae-379 | 6.65       | 52     | F   | 50-55      | 9            | 40.2          | 4.98                      | 15.02                                  |
| Mae-384 | 2.65       | 37.5   | M   | 35-40      | 109          | 31.4          | 6.37                      | 13.63                                  |
| Mae-390 | 9.65       | 45.5   | M   | 45-50      | 34           | 32            | 6.25                      | 13.75                                  |
| Mae-396 | 7.65       | 46.5   | F   | 45-50      | 35           | 42.2          | 4.74                      | 15.26                                  |
| Mae-399 | 9.65       | 43.5   | M   | 40-45      | 11           | 29.8          | 6.71                      | 13.29                                  |
| Mae-403 | 5.65       | 48     | M   | 45-50      | 111          | 50.8          | 3.94                      | 16.06                                  |
| Mae-405 | 3.65       | 46.5   | F   | 45-50      | 112          | 34.2          | 5.85                      | 14.15                                  |
| Mae-410 | 4.65       | 50.5   | F   | 50-55      | 50           | 75.8          | 2.64                      | 17.36                                  |
| Mae-414 | 3.65       | 43     | M   | 40-45      | 38           | 51            | 3.92                      | 16.08                                  |
| Mae-421 | 6.65       | 52.5   | F   | 50-55      | 14           | 19.65         | 10.18                     | 9.82                                   |
| Mae-422 | 0.65       | 19     | M   | 15-20      | 51           | 48.5          | 4.12                      | 15.88                                  |
| Mae-424 | 0.65       | 16.5   | F   | 15-20      | 115          | 37.6          | 5.32                      | 14.68                                  |
| Mae-428 | 10.2       | 54     | F   | 50-55      | 52           | 108           | 1.85                      | 18.15                                  |
| Mae-432 | 10.2       | 55.5   | F   | 55-60      | 146          | 35.8          | 5.59                      | 14.41                                  |
| Mae-436 | 7.2        | 60     | F   | 55-60      | 118          | 46.6          | 4.29                      | 15.71                                  |
| Mae-440 | 7.2        | 59     | F   | 55-60      | 54           | 33.3          | 6.01                      | 13.99                                  |
| Mae-441 | 10.2       | 64     | F   | 60-65      | 119          | 35.8          | 5.59                      | 14.41                                  |
| Mae-474 | 10.2       | 44     | M   | 40-45      | 151          | 34            | 5.88                      | 14.12                                  |
| Mae-449 | 7.2        | 52.5   | F   | 50-55      | 121          | 24.2          | 8.26                      | 11.74                                  |
| Mae-454 | 3.2        | 41     | M   | 40-45      | 122          | 33.2          | 6.02                      | 13.98                                  |
| Mae-464 | 10.2       | 59     | F   | 55-60      | 58           | 107           | 1.87                      | 18.13                                  |
| Mae-468 | 3.2        | 55     | F   | 50-55      | 69           | 19.3          | 10.36                     | 9.64                                   |
| Mae-470 | 2.2        | 33     | F   | 30-35      | 59           | 85.6          | 2.34                      | 17.66                                  |
| Mae-475 | 9.2        | 55     | F   | 50-55      | 126          | 24.8          | 8.06                      | 11.94                                  |
| Mae-477 | 4.2        | 51.5   | M   | 50-55      | 71           | 56.2          | 3.56                      | 16.44                                  |
| Mae-481 | 2.2        | 34.5   | F   | 30-35      | 127          | 16.1          | 12.42                     | 7.58                                   |
| Mae-488 | 3.2        | 39     | F   | 35-40      | 128          | 24.8          | 8.06                      | 11.94                                  |
| Mae-495 | 2.2        | 35     | F   | 30-35      | 62           | 71.8          | 2.79                      | 17.21                                  |
| Mae-496 | 3.2        | 47     | F   | 45-50      | 73           | 39.2          | 5.10                      | 14.90                                  |
| Mae-499 | 10.2       | 54     | M   | 50-55      | 130          | 34.2          | 5.85                      | 14.15                                  |
| Mae-501 | 4.2        | 51.5   | M   | 50-55      | 132          | 42.2          | 4.74                      | 15.26                                  |
| Mae-502 | 5.2        | 60.5   | F   | 60-65      | 74           | 12.2          | 16.39                     | 3.61                                   |
| Mae-509 | 5.2        | 51.5   | M   | 50-55      | 134          | 20.4          | 9.80                      | 10.20                                  |
| Mae-512 | 2.2        | 36     | M   | 35-40      | 77           | 23.6          | 8.47                      | 11.53                                  |
| Mae-519 | 5.2        | 50     | F   | 45-50      | 78           | 23            | 8.70                      | 11.30                                  |
| Mae-520 | 3.2        | 35.5   | F   | 35-40      | 138          | 36.2          | 5.52                      | 14.48                                  |
| Mae-524 | 10.2       | 52.5   | M   | 50-55      | 140          | 14.4          | 13.89                     | 6.11                                   |
| Mae-525 | 7.2        | 53.5   | M   | 50-55      | 80           | 30            | 6.67                      | 13.33                                  |
| Mae-533 | 2.2        | 36     | F   | 35-40      | 82           | 39.4          | 5.08                      | 14.92                                  |
| Mae-535 | 8.2        | 51.5   | F   | 50-55      | 84           | 24.4          | 8.20                      | 11.80                                  |
| Mae-537 | 1.2        | 23.5   | M   | 20-25      | 86           | 21.8          | 9.17                      | 10.83                                  |
| Mae-265 | 0.65       | 20.5   | F   | 20-25      | 15           | 23.7          | 8.44                      | 11.56                                  |
| Mae-271 | 0.65       | 18     | M   | 15-20      | 16           | 17.75         | 11.27                     | 8.73                                   |
| Mae-275 | 1.65       | 28.5   | F   | 25-30      | 40           | 34.3          | 5.83                      | 14.17                                  |
| Mae-282 | 4.65       | 49.5   | F   | 45-50      | 2            | 26.2          | 7.63                      | 12.37                                  |
| Mae-284 | 9.65       | 57.5   | F   | 55-60      | 89           | 16.2          | 12.35                     | 7.65                                   |
| Mae-286 | 3.65       | 41     | M   | 40-45      | 90           | 23            | 8.70                      | 11.30                                  |
| Mae-288 | 6.65       | 45.5   | F   | 45-50      | 42           | 68.9          | 2.90                      | 17.10                                  |
| Mae-292 | 2.65       | 44     | F   | 40-45      | 91           | 21.8          | 9.17                      | 10.83                                  |
| Mae-299 | 0.65       | 17.5   | M   | 15-20      | 3            | 18.5          | 10.81                     | 9.19                                   |
| Mae-300 | 1.65       | 35     | F   | 30-35      | 95           | 16            | 12.50                     | 7.50                                   |
| Mae-303 | 9.65       | 46.5   | M   | 45-50      | 96           | 14            | 14.29                     | 5.71                                   |
| Mae-304 | 8.65       | 54.5   | F   | 50-55      | 141          | 20.6          | 9.71                      | 10.29                                  |
| Mae-324 | 4.65       | 50     | M   | 45-50      | 5            | 21            | 9.52                      | 10.48                                  |
| Mae-325 | 6.65       | 52     | M   | 50-55      | 100          | 27.6          | 7.25                      | 12.75                                  |
| Mae-331 | 2.65       | 43     | F   | 40-45      | 45           | 67.7          | 2.95                      | 17.05                                  |
| Mae-332 | 9.65       | 55.5   | M   | 55-60      | 101          | 17.4          | 11.49                     | 8.51                                   |
| Mae-334 | 4.65       | 52.5   | F   | 50-55      | 23           | 63.4          | 3.15                      | 16.85                                  |
| Mae-337 | 7.65       | 54.5   | F   | 50-55      | 24           | 58.8          | 3.40                      | 16.60                                  |
| Mae-340 | 6.65       | 57.5   | M   | 55-60      | 25           | 24.4          | 8.20                      | 11.80                                  |
| Mae-346 | 9.65       | 57     | M   | 55-60      | 7            | 41            | 4.88                      | 15.12                                  |
| Mae-348 | 2.65       | 39     | F   | 35-40      | 103          | 23.6          | 8.47                      | 11.53                                  |
| Mae-351 | 5.65       | 50.5   | F   | 50-55      | 28           | 20.6          | 9.71                      | 10.29                                  |
| Mae-355 | 1.65       | 31     | M   | 30-35      | 29           | 48.4          | 4.13                      | 15.87                                  |
| Mae-358 | 1.65       | 26     | M   | 25-30      | 144          | 30.2          | 6.62                      | 13.38                                  |
| Mae-363 | 6.65       | 55     | F   | 50-55      | 8            | 46.4          | 4.31                      | 15.69                                  |
| Mae-364 | 3.65       | 44     | M   | 40-45      | 106          | 9.6           | 20.83                     | -0.83                                  |
| Mae-366 | 2.65       | 37.5   | F   | 35-40      | 47           | 46.9          | 4.26                      | 15.74                                  |
| Mae-374 | 2.65       | 46     | F   | 45-50      | 32           | 82.8          | 2.42                      | 17.58                                  |
| Mae-377 | 1.65       | 34     | M   | 30-35      | 108          | 28.8          | 6.94                      | 13.06                                  |
| Mae-381 | 6.65       | 57     | F   | 55-60      | 33           | 24            | 8.33                      | 11.67                                  |
| Mae-386 | 7.65       | 59     | F   | 55-60      | 110          | 22.2          | 9.01                      | 10.99                                  |
| Mae-394 | 9.65       | 54.5   | F   | 50-55      | 145          | 24            | 8.33                      | 11.67                                  |
| Mae-398 | 1.65       | 28.5   | F   | 25-30      | 36           | 19.5          | 10.26                     | 9.74                                   |
| Mae-404 | 4.65       | 51.5   | M   | 50-55      | 49           | 53.3          | 3.75                      | 16.25                                  |
| Mae-407 | 7.65       | 44     | F   | 40-45      | 12           | 54.8          | 3.65                      | 16.35                                  |
| Mae-409 | 3.65       | 52.5   | F   | 50-55      | 113          | 19.5          | 10.26                     | 9.74                                   |
| Mae-412 | 0.65       | 16     | M   | 15-20      | 37           | 21            | 9.52                      | 10.48                                  |
| Mae-418 | 9.65       | 52     | M   | 50-55      | 13           | 37.2          | 5.38                      | 14.62                                  |
| Mae-423 | 0.65       | 21.5   | F   | 20-25      | 114          | 25.6          | 7.81                      | 12.19                                  |
| Mae-426 | 7.2        | 61     | F   | 60-65      | 116          | 29.6          | 6.76                      | 13.24                                  |
| Mae-431 | 10.2       | 58     | F   | 55-60      | 53           | 28.2          | 7.09                      | 12.91                                  |
| Mae-435 | 10.2       | 55     | F   | 50-55      | 63           | 27.6          | 7.25                      | 12.75                                  |
| Mae-438 | 7.2        | 57     | F   | 55-60      | 64           | 24            | 8.33                      | 11.67                                  |
| Mae-443 | 1.2        | 23.5   | M   | 20-25      | 120          | 17            | 11.76                     | 8.24                                   |
| Mae-447 | 7.2        | 60     | F   | 55-60      | 55           | 38.8          | 5.15                      | 14.85                                  |
| Mae-450 | 5.2        | 53     | F   | 50-55      | 56           | 34.1          | 5.87                      | 14.13                                  |
| Mae-451 | 3.2        | 45.5   | M   | 45-50      | 66           | 11.1          | 18.02                     | 1.98                                   |
| Mae-456 | 4.2        | 46     | M   | 45-50      | 67           | 21.2          | 9.43                      | 10.57                                  |
| Mae-458 | 3.2        | 41     | F   | 40-45      | 57           | 72.8          | 2.75                      | 17.25                                  |
| Mae-459 | 1.2        | 22.5   | F   | 20-25      | 123          | 29.4          | 6.80                      | 13.20                                  |
| Mae-430 | 10.2       | 51     | F   | 50-55      | 149          | 17.95         | 11.14                     | 8.86                                   |
| Mae-466 | 2.2        | 29.5   | M   | 25-30      | 124          | 33.8          | 5.92                      | 14.08                                  |
| Mae-472 | 10.2       | 47     | M   | 45-50      | 125          | 37.2          | 5.38                      | 14.62                                  |
| Mae-473 | 2.2        | 33.5   | M   | 30-35      | 70           | 23.9          | 8.37                      | 11.63                                  |
| Mae-479 | 3.2        | 43     | M   | 40-45      | 60           | 35.1          | 5.70                      | 14.30                                  |
| Mae-482 | 2.2        | 38     | F   | 35-40      | 72           | 28.6          | 6.99                      | 13.01                                  |
| Mae-486 | 7.2        | 56.5   | F   | 55-60      | 61           | 30.2          | 6.62                      | 13.38                                  |
| Mae-494 | 3.2        | 43.5   | M   | 40-45      | 129          | 36.2          | 5.52                      | 14.48                                  |
| Mae-500 | 4.2        | 43     | F   | 40-45      | 131          | 26.4          | 7.58                      | 12.42                                  |
| Mae-504 | 3.2        | 42     | F   | 40-45      | 133          | 11.2          | 17.86                     | 2.14                                   |
| Mae-508 | 5.2        | 48     | M   | 45-50      | 75           | 29.4          | 6.80                      | 13.20                                  |
| Mae-510 | 6.2        | 53.5   | F   | 50-55      | 76           | 38            | 5.26                      | 14.74                                  |
| Mae-511 | 2.2        | 31     | M   | 30-35      | 135          | 13.3          | 15.04                     | 4.96                                   |
| Mae-517 | 10.2       | 46.5   | M   | 45-50      | 136          | 30.2          | 6.62                      | 13.38                                  |
| Mae-518 | 5.2        | 54.5   | F   | 50-55      | 137          | 26.2          | 7.63                      | 12.37                                  |
| Mae-522 | 5.2        | 59.5   | F   | 55-60      | 79           | 35.2          | 5.68                      | 14.32                                  |
| Mae-523 | 2.2        | 35     | F   | 30-35      | 139          | 19.2          | 10.42                     | 9.58                                   |
| Mae-530 | 7.2        | 51     | M   | 50-55      | 81           | 23.6          | 8.47                      | 11.53                                  |
| Mae-534 | 3.2        | 44     | M   | 40-45      | 83           | 44.8          | 4.46                      | 15.54                                  |
| Mae-536 | 2.2        | 40     | F   | 35-40      | 85           | 26.4          | 7.58                      | 12.42                                  |

## UDI prep 

Plate from Zymo 

|   | 1      | 2      | 3      | 4      | 5      | 6      | 7      | 8      | 9      | 10     | 11     | 12     |
|---|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
| A | UDI_01 | UDI_09 | UDI_17 | UDI_25 | UDI_33 | UDI_41 | UDI_49 | UDI_57 | UDI_65 | UDI_73 | UDI_81 | UDI_89 |
| B | UDI_02 | UDI_10 | UDI_18 | UDI_26 | UDI_34 | UDI_42 | UDI_50 | UDI_58 | UDI_66 | UDI_74 | UDI_82 | UDI_90 |
| C | UDI_03 | UDI_11 | UDI_19 | UDI_27 | UDI_35 | UDI_43 | UDI_51 | UDI_59 | UDI_67 | UDI_75 | UDI_83 | UDI_91 |
| D | UDI_04 | UDI_12 | UDI_20 | UDI_28 | UDI_36 | UDI_44 | UDI_52 | UDI_60 | UDI_68 | UDI_76 | UDI_84 | UDI_92 |
| E | UDI_05 | UDI_13 | UDI_21 | UDI_29 | UDI_37 | UDI_45 | UDI_53 | UDI_61 | UDI_69 | UDI_77 | UDI_85 | UDI_93 |
| F | UDI_06 | UDI_14 | UDI_22 | UDI_30 | UDI_38 | UDI_46 | UDI_54 | UDI_62 | UDI_70 | UDI_78 | UDI_86 | UDI_94 |
| G | UDI_07 | UDI_15 | UDI_23 | UDI_31 | UDI_39 | UDI_47 | UDI_55 | UDI_63 | UDI_71 | UDI_79 | UDI_87 | UDI_95 |
| H | UDI_08 | UDI_16 | UDI_24 | UDI_32 | UDI_40 | UDI_48 | UDI_56 | UDI_64 | UDI_72 | UDI_80 | UDI_88 | UDI_96 |

## Results: Qubit 

20230912 and 20230913: 2 samples 
- 0913 -- 2 samples of PMS: Start 9:30 am End 2:00 pm. Qubit same day and wait to put these samples on fragment analyzer with Sam's to avoid wasting the other 45 wells.

20230919 (10 samples): ~5 hours for 10 samples. I feel like I can increase the number processed at a time here too. AMM was short on last sample so re-made for 1. This went well and I'm way more comfortable with this protocol than the first couple times I did it in the Putnam Lab.

20230920 (12 samples): ~5.5-6 hr fro 12 samples. I can definitely increase this number if I use a multi-channel for the bead cleaning steps. One sample read too low on the qubit and another was 5.2 ng/uL. I can re-amp the 5.2 ng/uL sample or re-do it entirely.. The limiting factor is the 2X pre mix, but we have an extra tube of that from Zymo. We have the columns needed for this so come back to this at the end.

20231003: Final library preparation (batch of 20 samples). Fragment analyzer 20231004 but all qubit values look good.

**Qubit standards** 

| Date     | Standard 1 | Standard 2 | Sample Dates/Batches |
|----------|------------|------------|----------------------|
| 20230913 | 34.83      | 25,502.22  | 20230913 round of 2  |
| 20230919 | 45.14      | 25,461.00  | Sample 3-7           |
| 20230919 | 45.28      | 25,158.67  | Sample 8-12          |
| 20230920 | 42.73      | 26,362.95  | Sample 13-24         |
| 20230929 | 35.95      | 19,398.96  | Sample 25-56         |

**Qubit samples and Fragment analyzer peaks** 

| Seq Rnd | GMGI_ID | Final Ext ID | Zymo UDI # | Pico # | Pico Date   | Peak bp size | Qubit (ng/uL) | Final?                              | Pico methyl seq   notes                                                                         |
|---------|---------|--------------|------------|--------|-------------|--------------|---------------|-------------------------------------|-------------------------------------------------------------------------------------------------|
| 1       | Mae-263 | 1            | 1          | 1      | 20230912-13 | 235          | 16.8          | Yes                                 | 20230912 bisulfite   conversation left overnight at 4C; 1:100 on fragment analyzer              |
| 1       | Mae-266 | 39           | 2          | 2      | 20230912-13 | 265          | 16.5          | Yes                                 | 20230912 bisulfite   conversation left overnight at 4C; 1:100 on fragment analyzer              |
| 1       | Mae-274 | 87           | 3          | 3      | 20230918-19 | 248          | 12.4          | Yes                                 | 0918 overnight BC                                                                               |
| 1       | Mae-278 | 88           | 4          | 4      | 20230918-19 | 257          | 11.0          | Yes                                 | 0918 overnight BC                                                                               |
| 1       | Mae-281 | 17           | 5          | 5      | 20230918-19 | 223          | 8.6           | Yes                                 | 0918 overnight BC                                                                               |
| 1       | Mae-285 | 41           | 6          | 6      | 20230918-19 | 245          | 18.6          | Yes                                 | 0918 overnight BC                                                                               |
| 1       | Mae-293 | 92           | 7          | 7      | 20230918-19 | 259          | 14.7          | Yes                                 | 0918 overnight BC                                                                               |
| 1       | Mae-294 | 93           | 8          | 8      | 20230918-19 | 291          | 16.4          | Yes                                 | 0918 overnight BC                                                                               |
| 1       | Mae-295 | 18           | 9          | 9      | 20230918-19 | 224          | 10.0          | Yes                                 | 0918 overnight BC                                                                               |
| 1       | Mae-298 | 94           | 10         | 10     | 20230918-19 | 283          | 18.4          | Yes                                 | 0918 overnight BC                                                                               |
| 1       | Mae-302 | 43           | 11         | 11     | 20230918-19 | 246          | 21.6          | Yes                                 | 0918 overnight BC                                                                               |
| 1       | Mae-305 | 97           | 12         | 12     | 20230918-19 | 252          | 21.4          | Yes                                 | 0918 overnight BC                                                                               |
| 1       | Mae-310 | 4            | 13         | 13     | 20230919-20 | 270          | 17            | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-311 | 98           | 14         | 14     | 20230919-20 | 302          | 16.4          | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-317 | 44           | 15         | 15     | 20230919-20 | 295          | 20            | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-322 | 142          | 16         | 16     | 20230919-20 | 293          | 16.1          | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-327 | 20           | 17         | 17     | 20230919-20 | 251          | 15.7          | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-329 | 21           | 18         | 18     | 20230919-20 | 253          | 13.5          | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-330 | 143          | 19         | 19     | 20230919-20 | 290          | 17            | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-338 | 6            | 20         | 20     | 20230919-20 | too low      | too low       | Redo; sample thrown   out 20231002  | 0919 overnight BC;   throw this sample out                                                      |
|         |         |              | 20         | 20     | 20231002-03 | 295          | 13.6          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-342 | 26           | 21         | 21     | 20230919-20 | 309          | 16.2          | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-343 | 102          | 22         | 22     | 20230919-20 | 319          | 10.8          | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-344 | 46           | 23         | 23     | 20230919-20 | 306          | 15.1          | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-350 | 27           | 24         | 24     | 20230919-20 | 243          | 5.2           | Yes                                 | 0919 overnight BC                                                                               |
| 1       | Mae-352 | 104          | 25         | 25     | 20230926-7  | 262          | 28.8          | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-356 | 30           | 26         | 26     | 20230926-7  | 262          | 27.2          | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-368 | 107          | 27         | 27     | 20230926-7  | 255          | 30            | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-371 | 31           | 28         | 28     | 20230926-7  | 270          | 30.6          | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-378 | 48           | 29         | 29     | 20230926-7  | 261          | 23.6          | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-379 | 9            | 30         | 30     | 20231002-03 | 291          | 18.4          | Yes                                 | 0926 overnight BC;   contamined and stopped during process on 0927; redo; 20231002 overnight BC |
| 1       | Mae-384 | 109          | 31         | 31     | 20231002-03 | 286          | 15.4          | Yes                                 | 0926 overnight BC;   contamined and stopped during process on 0927; redo; 20231002 overnight BC |
| 1       | Mae-390 | 34           | 32         | 32     | 20231002-03 | 274          | 17.1          | Yes                                 | 0926 overnight BC;   contamined and stopped during process on 0927; redo; 20231002 overnight BC |
| 1       | Mae-396 | 35           | 33         | 33     | 20230926-7  | 266          | 25.6          | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-399 | 11           | 34         | 34     | 20230926-7  | 284          | 16.6          | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-403 | 111          | 35         | 35     | 20230926-7  | 294          | 12            | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-405 | 112          | 36         | 36     | 20230926-7  | 315          | 11.2          | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-410 | 50           | 37         | 37     | 20230926-7  | 276          | 23            | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-414 | 38           | 38         | 38     | 20230926-7  | 268          | 20            | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-421 | 14           | 39         | 39     | 20230926-7  | 262          | 7.62          | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-422 | 51           | 40         | 40     | 20230926-7  | 247          | 13.9          | Yes                                 | 0926 overnight BC                                                                               |
| 1       | Mae-424 | 115          | 41         | 41     | 20230927-8  | 216          | 15.9          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-428 | 52           | 42         | 42     | 20230927-8  | 251          | 36.4          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-432 | 146          | 43         | 43     | 20230927-8  | 263          | 13.1          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-436 | 118          | 44         | 44     | 20230927-8  | 286          | 21.2          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-440 | 54           | 45         | 45     | 20230927-8  | 239          | 18.8          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-441 | 119          | 46         | 46     | 20230927-8  | 240          | 22            | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-495 | 62           | 47         | 47     | 20230927-8  | too low      | 1.05          | Re-do; sample thrown   out 20231002 | 0927 overnight BC;   switched GMG IDs; throw out                                                |
|         |         |              | 47         | 47     | 20231002-03 | 278          | 19.5          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-449 | 121          | 48         | 48     | 20230927-8  | too low      | 1.53          | Re-do; sample thrown   out 20231002 | 0927 overnight BC;   throw out                                                                  |
|         |         |              | 48         | 48     | 20231002-03 | 273          | 11.3          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-454 | 122          | 49         | 49     | 20230927-8  | 242          | 20.4          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-464 | 58           | 50         | 50     | 20230927-8  | 259          | 20.8          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-468 | 69           | 51         | 51     | 20230927-8  | 280          | 25.4          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-470 | 59           | 52         | 52     | 20230927-8  | 258          | 19.3          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-475 | 126          | 53         | 53     | 20230927-8  | 284          | 31.2          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-477 | 71           | 54         | 54     | 20230927-8  | 284          | 20.8          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-481 | 127          | 55         | 55     | 20230927-8  | 291          | 19.9          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-488 | 128          | 56         | 56     | 20230927-8  | 283          | 14.7          | Yes                                 | 0927 overnight BC                                                                               |
| 1       | Mae-474 | 151          | 57         | 57     | 20231002-03 | 287          | 13.2          | Yes                                 | switch GMGI IDs                                                                                 |
| 1       | Mae-496 | 73           | 58         | 58     | 20231002-03 | 303          | 17.2          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-499 | 130          | 59         | 59     | 20231002-03 | 252          | 8.94          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-501 | 132          | 60         | 60     | 20231002-03 | 285          | 15.8          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-502 | 74           | 61         | 61     | 20231002-03 | 241          | 9.7           | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-509 | 134          | 62         | 62     | 20231002-03 | 291          | 15.8          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-512 | 77           | 63         | 63     | 20231002-03 | 272          | 10.5          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-519 | 78           | 64         | 64     | 20231002-03 | 273          | 15.1          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-520 | 138          | 65         | 65     | 20231002-03 | 239          | 13.9          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-524 | 140          | 66         | 66     | 20231002-03 | 240          | 21.4          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-525 | 80           | 67         | 67     | 20231002-03 | 316          | 12.3          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-533 | 82           | 68         | 68     | 20231002-03 | 273          | 11.9          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-535 | 84           | 69         | 69     | 20231002-03 | 293          | 14.6          | Yes                                 | 1002 overnight BC                                                                               |
| 1       | Mae-537 | 86           | 70         | 70     | 20231002-03 | 316          | 14.5          | Yes                                 | 1002 overnight BC                                                                               |

## Results: Fragment analyzer 

Fragment sizes range from 150 bp – 500 bp. All results are located here: https://github.com/emmastrand/GMGI_Notebook/tree/main/lab%20work/2023%20Haddock%20Pico%20Methyl%20Seq. Peak size is noted in section above. 

### 20230915 notes

We have the High Sensitivity Kit for the fragment analyzer. The manual says the DNA input is 5-500 pg/uL as input so I diluted my sample 1:100, but this means our peak is quite small. I'll dilute 1:10 when I run another fragment analyzer to make sure these are OK. The DNA quantity looks good and in the images below, the quality looks smooth as well.

### 20230929 Notes

I did a 1:10 dilution for theses samples but several appear to have a small peak with the bp size in the correct range but the qubit value is higher.. So maybe I didn't do the dilution correctly..? I'll re-analzye multiple with no dilution and double check they're OK. 

### 20231004 Notes 

I used a 1:10 dilution again and am re-analyzing some samples previously. Redid one more on 20231005.

### Examples of what the results look like:  

![](https://github.com/emmastrand/GMGI_Notebook/blob/main/lab%20work/2023%20Haddock%20Pico%20Methyl%20Seq/Pico1.png?raw=true)
![](https://github.com/emmastrand/GMGI_Notebook/blob/main/lab%20work/2023%20Haddock%20Pico%20Methyl%20Seq/Pico2.png?raw=true)