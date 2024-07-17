QC of WGBS and methylation pipeline
================
Authors: Emma Strand; <emma.strand@gmgi.org>

### Load libraries

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(tidyr)
library(ggplot2)
library(readxl) ## read excel file 
library(writexl) ## write excel file 
library(strex)
```

    ## Loading required package: stringr

``` r
library(ggpubr)
library(cowplot)
```

    ## 
    ## Attaching package: 'cowplot'

    ## The following object is masked from 'package:ggpubr':
    ## 
    ##     get_legend

## Read in data

Read in haddock alignment and bioinformatic processes data

``` r
WGBS_data <- read_xlsx("data/01_QC/bioinfo_stats.xlsx") %>% 
  ## creating sample ID column 
  mutate(GMGI_ID = str_before_first(`Sample Name`, "_")) %>% dplyr::select(-`Sample Name`) %>%
  ## relocating columns
  relocate(GMGI_ID, .before = Percent_Aligned) %>% relocate(M_C, .after = GMGI_ID) %>%
  ## change proportions to percentages
  mutate(across(Percent_Aligned:Methylated_CHH, ~ .x*100))
```

Read in results from e.coli alignment and calculating conversion
efficiency

``` r
ecoli_data <- read.delim2(file = "data/03_bisulfite_conversion_efficiency/ecoli_seqrun1_align.txt", header=T) %>%
  mutate(., GMGI_ID = str_before_nth(File, "_", 1),
         GMGI_ID = gsub("./", "", GMGI_ID)) %>% 
  ## calculating percent aligned to ecoli genome
  mutate(per_aligned = (Aligned.Reads/Total.Reads)*100) %>%
  ## calculating bisulfite conversion efficiency
  mutate(totalCHH = Methylated.CHHs + Unmethylated.CHHs,
         totalCHG = Methylated.chgs + Unmethylated.chgs,
         unmethCHH_CHG = Unmethylated.CHHs + Unmethylated.chgs,
         total_CHH_CHG = totalCHH + totalCHG,
         conv_eff = (unmethCHH_CHG/total_CHH_CHG)*100) %>%
  dplyr::select(GMGI_ID, per_aligned, conv_eff)
```

Bring in metadata to combine with ecoli and wgbs data

``` r
metadata <- read_xlsx("data/00_metadata/full_finclips_sampling.xlsx")
labwork <- read_xlsx("C:/BoxDrive/Box/Science/Fisheries/Projects/Epigenetic Aging/Haddock/Labwork/Haddock_labwork.xlsx", sheet = "Sample List") %>% dplyr::select(GMGI_ID, `Seq Rnd`)
metadata <- full_join(metadata, labwork, by="GMGI_ID")

data <- right_join(metadata, ecoli_data, by="GMGI_ID") %>% left_join(., WGBS_data, by = "GMGI_ID")

data$`Seq Rnd` <- as.character(data$`Seq Rnd`)
```

## Plotting

``` r
supp_fig <- data %>% gather("measurement", "value", c(per_aligned:Percent_mCHH)) %>%
  ggplot(., aes(x=`Seq Rnd`, y=value, fill=`Seq Rnd`)) + 
  theme_bw() +
  geom_boxplot(outlier.shape = NA, alpha=0.3, width=0.6, fill="white", color="grey55", linewidth=1) + 
  geom_jitter(size=2.5, alpha=0.6, width=0.15, shape=21, color="black") +
  xlab("Sequencing Round") +
  ylab("") +
  guides(fill = "none") +
  facet_wrap(~factor(measurement, levels = c("per_aligned", "conv_eff", "M_C", 
                                             "Percent_Aligned", "Percent_Dups", "Percent_mCHG",
                                             "Percent_mCHH", "Percent_mCpG")), 
             scales = "free", strip.position = "left",
             labeller = as_labeller(c(conv_eff = "Bisulfite conversion efficiency (%)",
                                      M_C = "Number of cytosine's (Mil.)",
                                      Percent_mCHG = "CHG methylation (%)",
                                      Percent_mCHH = "CHH methylation (%)",
                                      Percent_mCpG = "CpG methylation (%)",
                                      per_aligned = "E.coli alignment (%)",
                                      Percent_Aligned = "Haddock alignment (%)",
                                      Percent_Dups = "Duplicated reads (%)"))
             ) +
  scale_fill_manual(values = c("indianred3")) +
  theme(panel.background=element_rect(fill='white', colour='black'),
        strip.background = element_blank(), strip.placement = "outside",
        strip.text = element_text(size = 12, face="bold"),
        strip.text.y.left = element_text(size=10, color = "black", face = "bold"),
        axis.text.x = element_text(size=11, color="black"),
        axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0), size=12, face="bold"),
        axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0), size=10, face="bold")); supp_fig
```

![](04b-Methylation_QC_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

``` r
ggsave("data/03_bisulfite_conversion_efficiency/QC.png", width=8, height=8)
```
