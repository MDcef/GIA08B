year <- 2019
species <- dbplyr::translate_sql(c('SAN', 'SPR'))

eflalo_sql <- glue::glue_sql ( "

with a as ( 
  
  SELECT 
  ve_ref , ve_flt , ve_cou  , ve_len  , ve_kw  , ve_ton  , ft_ref ,  ft_dcou  ,
  ft_dhar  ,ft_ddat::text   ,ft_dtime::text  ,ft_ddatim::text   , ft_lcou   ,ft_lhar  ,
  ft_ldat::text   ,ft_ltime  , ft_ldatim::text  , 
  le_id  , le_cdat::text  ,le_stime  ,  le_etime  ,le_slat ,le_slon  ,le_elat  ,le_elon  ,le_gear ,
  le_msz  ,le_rect ,le_div ,le_met  
  FROM 
  ( SELECT * FROM eflalo.eflalo_ft WHERE ft_year = {year} ) AS ft
  INNER JOIN eflalo.eflalo_le le 
  ON eflalo_ft_ft_Ref = ft_ref 	 
  
  
) , b as  (  
  
  SELECT le_gear as lgr, lc.le_spe::text, sum(lc.le_kg) AS le_kg, sum(lc.le_euro) AS le_euro, sum(total_lw) AS total_lw, sum(total_val) AS total_val, eflalo_le_le_id
  FROM
  (SELECT * FROM eflalo.landing_composition_2009_2020 WHERE ft_lyear = {year} AND total_lw_rat > 0.01 AND le_spe IN ('SAN', 'SPR')) AS lc 
  INNER JOIN eflalo.eflalo_spe spe
  on lc.ft_ref = spe.eflalo_ft_ft_ref
  GROUP BY lc.le_spe, le_gear, eflalo_le_le_id
  
) 

SELECT a.*, b.*
  FROM  a 
INNER JOIN b 
ON a.le_id = b.eflalo_le_le_id    ", .con = conn)


eflalo <- tbl( conn,   sql ( eflalo_sql ) )   %>%
  dplyr::rename_with(toupper)         %>%
  tibble::as_tibble()  %>%
  pivot_wider(
    names_from = 'LE_SPE',
    values_from = c('LE_KG','LE_EURO'),
    names_glue = '{.value}_{LE_SPE}' ,
    names_sort = TRUE,
    values_fill = 0)




print(glue('Dimension of eflalo col: {dim(eflalo)[2]}  :: Dimension of eflalo rows: {dim(eflalo)[1]}' )) 
eflalo -> bk
#eflalo <- bk


eflalo$FT_DDAT <-   ymd(eflalo$FT_DDAT  )  
eflalo$FT_LDAT <-   ymd(eflalo$FT_LDAT  ) 
eflalo$LE_CDAT <-   ymd(eflalo$LE_CDAT  ) 
eflalo$FT_DDATIM <- ymd_hms( eflalo$FT_DDATIM ) 
eflalo$FT_LDATIM <- ymd_hms( eflalo$FT_LDATIM ) 
#eflalo$LE_KG_TOT   <- eflalo$TOTAL_LE_ID_KG
#eflalo$LE_EURO_TOT <- eflalo$TOTAL_LE_ID_EUR
#eflalo$total_ft_ref_kg   <-  NULL
#eflalo$total_ft_ref_eur  <- NULL
eflalo$VE_COU <- 'GB'

eflalo$Year <- year(eflalo$FT_DDATIM )
eflalo$Month <- month(eflalo$FT_LDATIM)



unique_trips <- eflalo %>%distinct(FT_REF)%>%pull() 
tacsat_sql <- glue::glue_sql(' select  a.gid, a.si_ft, a.ve_ref, si_lati, si_long ,
              a.si_date::text,si_time,si_datim::text,
              si_sp,si_he,si_state,intv,
              le_gear,d.le_rect,ve_len,ve_kw,le_met ,
              le_msz,ve_flt,le_cdat::text,ve_cou  
    from (
        select a.*
		    from (
		        select *
		        from tacsat.tacsat a
		        where si_year = {year} and si_ft in ({unique_trips*})  and si_state = \'f\'
		        ) a
		     inner join tacsat.qc c
		      on a.gid = c.tacsat_gid
		          and in_port is false
		          and in_land is false
	  )  a
    inner join tacsat.tacsat_eflalo_le b
    on   a.gid = b.tacsat_gid and  row_n = 1
    inner join eflalo.eflalo_le d
    on b.le_id = d.le_id
    inner join  eflalo.eflalo_ft e
    on eflalo_ft_ft_ref = ft_ref  ', .con = conn )  

tacsat <- tbl( conn,   sql ( tacsat_sql ) ) %>%
  rename_with(toupper)                      %>%
  tibble::as_tibble()       

print(paste0('Dimension of tacsat: ',  dim(tacsat)   ))
tacsat$SI_DATE <-   ymd(tacsat$SI_DATE   )
tacsat$SI_DATIM <-  ymd_hms(tacsat$SI_DATIM)
tacsat$SI_STATE <- 'f'
tacsat$FT_REF <- tacsat$SI_FT
tacsat$VE_COU <- 'GB'
tacsatp <- tacsat

tacsatp$Csquare <- CSquare(tacsatp$SI_LONG, tacsatp$SI_LATI, degrees = 0.05)
