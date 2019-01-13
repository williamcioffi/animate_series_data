# quick look at series messages
rcsv <- function(..., header = TRUE, sep = ',', stringsAsFactors = FALSE) {
  read.table(..., header = header, sep = sep, stringsAsFactors = stringsAsFactors)
}

dateseq <- function(d, hours = FALSE) {
  unit <- 60*60*24 # day in seconds
  if(hours) unit <- 60*60 # hour in seconds

  mind <- min(d, na.rm = TRUE)
  maxd <- max(d, na.rm = TRUE)

  std <- trunc(mind / unit) * unit
  end <- ceiling(maxd / unit) * unit

  seq(std, end, by = unit)
}

num2date <- function(d, tz = 'UTC', origin = "1970-01-01") {
  as.POSIXct(d, tz = tz , origin = origin)
}

datadirpath <- "data"
datadir <- list.files(datadirpath)
serfiles <- datadir[grep("*s_.csv$", datadir)]
msgfiles <- datadir[grep("*sr.csv$", datadir)]
nsnaps <- length(datadir) / 2 # two streams

dates <- rcsv("fnames_s", header = FALSE)
datelabs <- sapply(strsplit(dates[, 1], "/"), "[[", 2)


png(width = 800, height = 300)
for(i in 1:nsnaps) {
  # load the last one to get the axis lims
  ser <- rcsv(file.path(datadirpath, serfiles[nsnaps]))
  msg <- rcsv(file.path(datadirpath, msgfiles[nsnaps]))

  date <- paste(ser$Day, ser$Time)
  dateposix <- as.POSIXct(date, tz = "UTC", format = "%d-%b-%Y %H:%M:%S")
  datenumer <- as.numeric(dateposix)
  maxmsgnum <- max(msg$Count)

  st <- as.numeric(as.POSIXct(msg$Start, tz = "UTC", format = "%H:%M:%S %d-%b-%Y"))
  en <- as.numeric(as.POSIXct(msg$End, tz = "UTC", format = "%H:%M:%S %d-%b-%Y"))

  plot(datenumer, rep(0, length(datenumer)), type = 'n', axes = FALSE, xlab = "", ylab = "", ylim = c(0, maxmsgnum))
  axis(3, at = c(st, en), labels = FALSE, tcl = .5)
  # axis(1, at = c(st, en), labels = FALSE, tcl = .5)

  dseq <- dateseq(datenumer, hours = FALSE)
  labs <- format(num2date(dseq), '%d-%b')
  axis(1, at = dseq, labels = labs, las = 2)
  axis(2, las = 1)
  box()

  ser <- rcsv(file.path(datadirpath, serfiles[i]))
  msg <- rcsv(file.path(datadirpath, msgfiles[i]))

  date <- paste(ser$Day, ser$Time)
  dateposix <- as.POSIXct(date, tz = "UTC", format = "%d-%b-%Y %H:%M:%S")
  datenumer <- as.numeric(dateposix)

  st <- as.numeric(as.POSIXct(msg$Start, tz = "UTC", format = "%H:%M:%S %d-%b-%Y"))
  en <- as.numeric(as.POSIXct(msg$End, tz = "UTC", format = "%H:%M:%S %d-%b-%Y"))

  diffs <- st[2:length(st)] - en[1:(length(st) - 1)]
  gaps <- which(diffs != 0)

  rect(en[gaps], rep(-2000, length(gaps)), st[gaps+1], rep(2000, length(gaps)), col = rgb(1, 0, 1, .25), border = NA)
  rect(st, 0, en, msg$Count)

  title(datelabs[i])
}
dev.off()

