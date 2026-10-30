## Prepare plots and tables for report

## Before: nep.fu.2829_input.csv (data), summary.csv (output)
## After:  report.html, summary.csv (report)

library(icesTAF)
library(rmarkdown)

mkdir("report")

## Read full-precision summary ----
summary <- read.taf("output/summary.csv")

# Round
summary <- round(summary, 3)


# Write rounded summary ----
write.taf(summary, dir="report")


# Render R Markdown ----
cp("report.Rmd", "report")
cp("data", "report")
render("report/report.Rmd", output_dir="report")
unlink("report/data", recursive=TRUE)
rmdir("report", recursive=TRUE)  # remove empty dirs
