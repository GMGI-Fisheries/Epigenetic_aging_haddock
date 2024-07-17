# Whole Genome Bisulfite Sequencing

We sequenced these WGBS libraries (built from [Zymo Pico Methyl Seq Kit](https://github.com/emmastrand/Epigenetic_aging/blob/main/protocols%20and%20lab%20work/03-PicoMethyl.md)) at the University of Connecticut Institute for Systems Genomics: [Center for Genome Innovation](https://cgi.uconn.edu/). 

We did two batches of 70 samples each. Each batch was repsentative of the age and length distributions we have in our dataset. Both batches were sequenced on a NovaSeq 6000 platform across S4 four flow cell lanes with Illumina NovaSeq 6000 S4 Reagent Kit v1.5 (300 cycles), catalog number 20028312. Each sample had their own Unique Dual Indices (UDI) set so we pooled all 70 samples together for sequencing. Pooling was performed at GMGI and then sent overnight shipping to UConn. 

Each pooled library was 310 uL total of 0.6 nM concentration. To calculate pooling, I used Illumina's pooling calculator: https://support.illumina.com/help/pooling-calculator/pooling-calculator.htm. I used the average peak bp size from fragment analyzer results. See the two tables below for calculations.

### Pooling Sequencing Round 1

Library Plexity: 70     
Unit of measure for library: ng/uL    
Library size: 268 bp     
Pooled Library Concentration (nM): 0.6 nM  
Total Pooled Library Volume (uL): 310 uL  


|        Sample ID | Library Concentration (ng/µl) | Library Volume (µl) | 10 mM Tris-HCl, pH 8.5 (µl) | Pooling Volume (µl) |
|--------------------|---------------------------------|---------------------|-------------------------------|---------------------|
| Mae-263            | 16.8                            | 2                   | 312.6                         | 4.4                 |
| Mae-266            | 16.5                            | 2                   | 306.9                         | 4.4                 |
| Mae-274            | 12.4                            | 2                   | 230.2                         | 4.4                 |
| Mae-278            | 11                              | 2                   | 204                           | 4.4                 |
| Mae-281            | 8.6                             | 2                   | 159                           | 4.4                 |
| Mae-285            | 18.6                            | 2                   | 346.3                         | 4.4                 |
| Mae-293            | 14.7                            | 2                   | 273.2                         | 4.4                 |
| Mae-294            | 16.4                            | 2                   | 305.1                         | 4.4                 |
| Mae-295            | 10                              | 2                   | 185.3                         | 4.4                 |
| Mae-298            | 18.4                            | 2                   | 342.5                         | 4.4                 |
| Mae-302            | 21.6                            | 2                   | 402.4                         | 4.4                 |
| Mae-305            | 21.4                            | 2                   | 398.7                         | 4.4                 |
| Mae-310            | 17                              | 2                   | 316.3                         | 4.4                 |
| Mae-311            | 16.4                            | 2                   | 305.1                         | 4.4                 |
| Mae-317            | 20                              | 2                   | 372.5                         | 4.4                 |
| Mae-322            | 16.1                            | 2                   | 299.4                         | 4.4                 |
| Mae-327            | 15.7                            | 2                   | 292                           | 4.4                 |
| Mae-329            | 13.5                            | 2                   | 250.8                         | 4.4                 |
| Mae-330            | 17                              | 2                   | 316.3                         | 4.4                 |
| Mae-338            | 13.6                            | 2                   | 252.6                         | 4.4                 |
| Mae-342            | 16.2                            | 2                   | 301.3                         | 4.4                 |
| Mae-343            | 10.8                            | 2                   | 200.2                         | 4.4                 |
| Mae-344            | 15.1                            | 2                   | 280.7                         | 4.4                 |
| Mae-350            | 5.2                             | 2                   | 95.4                          | 4.4                 |
| Mae-352            | 28.8                            | 2                   | 537.2                         | 4.4                 |
| Mae-356            | 27.2                            | 2                   | 507.3                         | 4.4                 |
| Mae-368            | 30                              | 2                   | 559.7                         | 4.4                 |
| Mae-371            | 30.6                            | 2                   | 570.9                         | 4.4                 |
| Mae-378            | 23.6                            | 2                   | 439.9                         | 4.4                 |
| Mae-379            | 18.4                            | 2                   | 342.5                         | 4.4                 |
| Mae-384            | 15.4                            | 2                   | 286.3                         | 4.4                 |
| Mae-390            | 17.1                            | 2                   | 318.2                         | 4.4                 |
| Mae-396            | 25.6                            | 2                   | 477.3                         | 4.4                 |
| Mae-399            | 16.6                            | 2                   | 308.8                         | 4.4                 |
| Mae-403            | 12                              | 2                   | 222.7                         | 4.4                 |
| Mae-405            | 11.2                            | 2                   | 207.7                         | 4.4                 |
| Mae-410            | 23                              | 2                   | 428.6                         | 4.4                 |
| Mae-414            | 20                              | 2                   | 372.5                         | 4.4                 |
| Mae-421            | 7.62                            | 2                   | 140.7                         | 4.4                 |
| Mae-422            | 13.9                            | 2                   | 258.2                         | 4.4                 |
| Mae-424            | 15.9                            | 2                   | 295.7                         | 4.4                 |
| Mae-428            | 36.4                            | 2                   | 679.5                         | 4.4                 |
| Mae-432            | 13.1                            | 2                   | 243.3                         | 4.4                 |
| Mae-436            | 21.2                            | 2                   | 395                           | 4.4                 |
| Mae-440            | 18.8                            | 2                   | 350                           | 4.4                 |
| Mae-441            | 22                              | 2                   | 409.9                         | 4.4                 |
| Mae-495            | 19.5                            | 2                   | 363.1                         | 4.4                 |
| Mae-449            | 11.3                            | 2                   | 209.6                         | 4.4                 |
| Mae-454            | 20.4                            | 2                   | 380                           | 4.4                 |
| Mae-464            | 20.8                            | 2                   | 387.4                         | 4.4                 |
| Mae-468            | 25.4                            | 2                   | 484.4                         | 4.5                 |
| Mae-470            | 19.3                            | 2                   | 367.6                         | 4.5                 |
| Mae-475            | 31.2                            | 2                   | 595.4                         | 4.5                 |
| Mae-477            | 20.8                            | 2                   | 396.3                         | 4.5                 |
| Mae-481            | 19.9                            | 2                   | 379.1                         | 4.5                 |
| Mae-488            | 14.7                            | 2                   | 279.5                         | 4.5                 |
| Mae-474            | 13.2                            | 2                   | 250.8                         | 4.5                 |
| Mae-496            | 17.2                            | 2                   | 327.4                         | 4.5                 |
| Mae-499            | 8.94                            | 2                   | 169.2                         | 4.5                 |
| Mae-501            | 15.8                            | 2                   | 300.6                         | 4.5                 |
| Mae-502            | 9.7                             | 2                   | 183.7                         | 4.5                 |
| Mae-509            | 15.8                            | 2                   | 300.6                         | 4.5                 |
| Mae-512            | 10.5                            | 2                   | 199.1                         | 4.5                 |
| Mae-519            | 15.1                            | 2                   | 287.2                         | 4.5                 |
| Mae-520            | 13.9                            | 2                   | 264.2                         | 4.5                 |
| Mae-524            | 21.4                            | 2                   | 407.8                         | 4.5                 |
| Mae-525            | 12.3                            | 2                   | 233.5                         | 4.5                 |
| Mae-533            | 11.9                            | 2                   | 225.9                         | 4.5                 |
| Mae-535            | 14.6                            | 2                   | 277.6                         | 4.5                 |
| Mae-537            | 14.5                            | 2                   | 275.7                         | 4.5                 |