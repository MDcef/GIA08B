linkEflaloTacsat          <- c("day","ICESrectangle","trip")


#eflalo            <- eflalo[,-idxkgeur]
eflaloNM          <- subset(eflalo,!FT_REF %in% unique(tacsatp$FT_REF))
eflaloM           <- subset(eflalo,FT_REF %in% unique(tacsatp$FT_REF))

print(paste0('Dimension of Non merged eflalo: ',  dim(eflaloNM)   ))
print(paste0('Dimension of  merged eflalo: ',  dim(eflaloM)   ))




tacsatp$SI_STATE[which(tacsatp$SI_STATE != "f")] <- 0
tacsatp$SI_STATE[which(tacsatp$SI_STATE == "f")] <- 1

tacsatp_df <- tacsatp%>%as.data.frame()
eflaloM_df <- eflaloM%>%as.data.frame()


tacsatEflalo  <- vmstools::splitAmongPings(tacsat=tacsatp_df,eflalo=eflaloM_df, 
                                           variable="all",level="day",conserve=T)
