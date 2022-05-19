
tacsatEflalo$Csquare   <- CSquare(tacsatEflalo$SI_LONG, tacsatEflalo$SI_LATI, degrees = 0.05)

tacsatEflalo$Year      <- year(tacsatEflalo$SI_DATIM)

tacsatEflalo$Month     <- month(tacsatEflalo$SI_DATIM)

tacsatEflalo$kwHour    <- tacsatEflalo$VE_KW * tacsatEflalo$INTV ##/ 60

tacsatEflalo$INTV      <- tacsatEflalo$INTV ##/ 60

tacsatEflalo$LENGTHCAT <- cut(tacsatEflalo$VE_LEN, breaks=c(0, 8, 10, 12, 15, 200))

tacsatEflalo$LENGTHCAT <- as.character(tacsatEflalo$LENGTHCAT)

tacsatEflalo$LENGTHCAT[which(tacsatEflalo$LENGTHCAT == "(0,8]")] <- "<8"

tacsatEflalo$LENGTHCAT[which(tacsatEflalo$LENGTHCAT == "(8,10]")] <- "8-10"

tacsatEflalo$LENGTHCAT[which(tacsatEflalo$LENGTHCAT == "(10,12]")] <- "10-12"

tacsatEflalo$LENGTHCAT[which(tacsatEflalo$LENGTHCAT == "(12,15]")] <- "12-15"

tacsatEflalo$LENGTHCAT[which(tacsatEflalo$LENGTHCAT == "(15,200]")] <- ">15"









eflalo$Year <- year(eflalo$FT_LDATIM)

eflalo$Month <- month(eflalo$FT_LDATIM)

eflalo$INTV <- 1 # 1 day

eflalo$dummy <- 1

res <-
  
  aggregate(
    
    eflalo$dummy,
    
    by = as.list(eflalo[, c("VE_COU", "VE_REF", "LE_CDAT")]),
    
    FUN = sum,
    
    na.rm <- TRUE
    
  )

colnames(res) <- c("VE_COU", "VE_REF", "LE_CDAT", "nrRecords")

eflalo <- merge(eflalo, res, by = c("VE_COU", "VE_REF", "LE_CDAT"))

eflalo$INTV <- eflalo$INTV / eflalo$nrRecords

eflalo$kwDays <- eflalo$VE_KW * eflalo$INTV

eflalo$tripInTacsat <- ifelse(eflalo$FT_REF %in% tacsatp$FT_REF, "Yes", "No")



eflalo$LENGTHCAT <- cut(eflalo$VE_LEN, breaks = c(0, 8, 10, 12, 15, 200))

eflalo$LENGTHCAT <- ac(eflalo$LENGTHCAT)

eflalo$LENGTHCAT[which(eflalo$LENGTHCAT == "(0,8]")] <- "<8"

eflalo$LENGTHCAT[which(eflalo$LENGTHCAT == "(8,10]")] <- "8-10"

eflalo$LENGTHCAT[which(eflalo$LENGTHCAT == "(10,12]")] <- "10-12"

eflalo$LENGTHCAT[which(eflalo$LENGTHCAT == "(12,15]")] <- "12-15"

eflalo$LENGTHCAT[which(eflalo$LENGTHCAT == "(15,200]")] <- ">15"



RecordType <- "LE"




# upload to the database
st_write(obj = tacsatEflalo, dsn = conn, Id(schema="eflalo", table = "san_spr_tacsat_eflalo_2019"), append = FALSE)
