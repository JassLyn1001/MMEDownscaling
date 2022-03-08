; Load NCL libraries
; ------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


;**********************************************************************
; Creat panel plots for future change extremes indicies
; relative to baseline period
;**********************************************************************

;-------- read in netCDF files

dirin   = "/mnt/d/Skripsi/Data_Jassica/Prog_Statistik/Multimodel_spasial/Indices_percentage/"
dirout  = "/mnt/d/Skripsi/Data_Jassica/Prog_Statistik/Tambahan_revisi/"
output  = "final_plot_allperiod_"
infile1 = addfile(dirin+"cdd_2021-2045_perc.nc","r")
infile2 = addfile(dirin+"cdd_2046-2070_perc.nc","r")
infile3 = addfile(dirin+"cdd_2071-2095_perc.nc","r")
infile4 = addfile(dirin+"cwd_2021-2045_perc.nc","r")
infile5 = addfile(dirin+"cwd_2046-2070_perc.nc","r")
infile6 = addfile(dirin+"cwd_2071-2095_perc.nc","r")
infile7 = addfile(dirin+"r10mm_2021-2045_perc.nc","r")
infile8 = addfile(dirin+"r10mm_2046-2070_perc.nc","r")
infile9 = addfile(dirin+"r10mm_2071-2095_perc.nc","r")
infile10 = addfile(dirin+"r20mm_2021-2045_perc.nc","r")
infile11 = addfile(dirin+"r20mm_2046-2070_perc.nc","r")
infile12 = addfile(dirin+"r20mm_2071-2095_perc.nc","r")
infile13 = addfile(dirin+"rx1day_2021-2045_perc.nc","r")
infile14 = addfile(dirin+"rx1day_2046-2070_perc.nc","r")
infile15 = addfile(dirin+"rx1day_2071-2095_perc.nc","r")
infile16 = addfile(dirin+"rx5day_2021-2045_perc.nc","r")
infile17 = addfile(dirin+"rx5day_2046-2070_perc.nc","r")
infile18 = addfile(dirin+"rx5day_2071-2095_perc.nc","r")

ntim = 1
nlat = 105
nlon = 277

minlat = -11.0
maxlat = 7.0
minlon = 94.50
maxlon = 141.50

var_1=infile1->consecutive_dry_days_index_per_time_period(:,:,:)
var_2=infile2->consecutive_dry_days_index_per_time_period(:,:,:)
var_3=infile3->consecutive_dry_days_index_per_time_period(:,:,:)

var_4=infile4->consecutive_wet_days_index_per_time_period(:,:,:)
var_5=infile5->consecutive_wet_days_index_per_time_period(:,:,:)
var_6=infile6->consecutive_wet_days_index_per_time_period(:,:,:)

var_7=infile7->r10mmETCCDI(:,:,:)
var_8=infile8->r10mmETCCDI(:,:,:)
var_9=infile9->r10mmETCCDI(:,:,:)

var_10=infile10->r20mmETCCDI(:,:,:)
var_11=infile11->r20mmETCCDI(:,:,:)
var_12=infile12->r20mmETCCDI(:,:,:)

var_13=infile13->rx1dayETCCDI(:,:,:)
var_14=infile14->rx1dayETCCDI(:,:,:)
var_15=infile15->rx1dayETCCDI(:,:,:)

var_16=infile16->rx5dayETCCDI(:,:,:)
var_17=infile17->rx5dayETCCDI(:,:,:)
var_18=infile18->rx5dayETCCDI(:,:,:)

;--------- creat plot

wks = gsn_open_wks("png", dirout+"/relative_obs_"+output+"_indices")

plot = new(18,graphic)                          ; create a plot array

res                     = True
res@gsnDraw             = False            ; don't draw
res@gsnFrame            = False            ; don't advance frame
res@gsnAddCyclic        = False
res@gsnMaximize         = True         ; make image as large as possible
res@gsnRightString      = "(%)"

res@mpFillOn                     = True
res@mpOutlineOn                  = True
res@pmTickMarkDisplayMode        = "Always"       ; Turn on map tickmarks
res@mpDataSetName                = "Earth..4"   ; This new database contains divisions for other countries
res@mpDataBaseVersion            = "MediumRes"  ; Medium resolution database
res@mpGeophysicalLineThicknessF  = 1.0
res@mpOutlineBoundarySets        = "National"   ; draw National boundaries
    mask_areas                   = "Indonesia"
res@mpMaskAreaSpecifiers         = mask_areas   ; keep these regions
res@mpOutlineSpecifiers          = mask_areas   ; outline these regions
res@mpLandFillColor              = 0                ;"Transparent"
res@mpOceanFillColor             = 0                ;"Transparent"
res@mpFillDrawOrder              = "PostDraw"   ; fille the ocean, land, and inland water last, but do not
                                                ; fill the areas specified in mpMaskAreaSpecifiers
                                                ; zoom in on map
res@mpMinLatF                    = minlat
res@mpMaxLatF                    = maxlat
res@mpMinLonF                    = minlon
res@mpMaxLonF                    = maxlon

res@cnFillOn                    = True             ; turn on color
res@cnInfoLabelOn               = False            ; turn off cn info label
res@cnLinesOn                   = False              ; Turn off contour lines
res@cnLineLabelsOn              = False              ; Turn off contour labels
res@cnFillPalette                = "cmp_b2r"        ;  (MPL_RdYlGn, MPL_RdYlBu, MPL_coolwarm)
res@cnFillMode                   = "RasterFill"    ; Raster Mode
res@cnRasterSmoothingOn          = True
res@lbLabelBarOn                 = False            ; turn off individual cb's

res@cnLevelSelectionMode         = "ManualLevels"     ; set manual contour levels
res@cnMinLevelValF               = -60.                ; set min contour level
res@cnMaxLevelValF               =  60.                ; set max contour level
res@cnLevelSpacingF              =  5              ; set contour spacing
res@tmXBLabelFontHeightF         = 0.02
res@tmYLLabelFontHeightF         = 0.02


res@gsnLeftString       =  "CDD Periode 2021-2045"
plot(0)                 = gsn_csm_contour_map(wks,var_1(0,:,:),res)

res@gsnLeftString       =  "CDD Periode 2046-2070"
plot(1)                 = gsn_csm_contour_map(wks,var_2(0,:,:),res)

res@gsnLeftString       =  "CDD Periode 2071-2095"
plot(2)                 = gsn_csm_contour_map(wks,var_3(0,:,:),res)

res@gsnLeftString       =  "CWD Periode 2021-2045"
plot(3)                 = gsn_csm_contour_map(wks,var_4(0,:,:),res)

res@gsnLeftString       =  "CWD Periode 2046-2070"
plot(4)                 = gsn_csm_contour_map(wks,var_5(0,:,:),res)

res@gsnLeftString       =  "CWD Periode 2071-2095"
plot(5)                 = gsn_csm_contour_map(wks,var_6(0,:,:),res)

res@gsnLeftString       =  "R10mm Periode 2021-2045"
plot(6)                 = gsn_csm_contour_map(wks,var_7(0,:,:),res)

res@gsnLeftString       =  "R10mm Periode 2046-2070"
plot(7)                 = gsn_csm_contour_map(wks,var_8(0,:,:),res)

res@gsnLeftString       =  "R10mm Periode 2071-2095"
plot(8)                 = gsn_csm_contour_map(wks,var_9(0,:,:),res)

res@gsnLeftString       =  "R20mm Periode 2021-2045"
plot(9)                 = gsn_csm_contour_map(wks,var_10(0,:,:),res)

res@gsnLeftString       =  "R20mm Periode 2046-2070"
plot(10)                 = gsn_csm_contour_map(wks,var_11(0,:,:),res)

res@gsnLeftString       =  "R20mm Periode 2071-2095"
plot(11)                 = gsn_csm_contour_map(wks,var_12(0,:,:),res)

res@gsnLeftString       =  "Rx1day Periode 2021-2045"
plot(12)                 = gsn_csm_contour_map(wks,var_13(0,:,:),res)

res@gsnLeftString       =  "Rx1day Periode 2046-2070"
plot(13)                 = gsn_csm_contour_map(wks,var_14(0,:,:),res)

res@gsnLeftString       =  "Rx1day Periode 2071-2095"
plot(14)                 = gsn_csm_contour_map(wks,var_15(0,:,:),res)

res@gsnLeftString       =  "Rx5day Periode 2021-2045"
plot(15)                 = gsn_csm_contour_map(wks,var_16(0,:,:),res)

res@gsnLeftString       =  "Rx5day Periode 2046-2070"
plot(16)                 = gsn_csm_contour_map(wks,var_17(0,:,:),res)

res@gsnLeftString       =  "Rx5day Periode 2071-2095"
plot(17)                 = gsn_csm_contour_map(wks,var_18(0,:,:),res)

; ---------  create panel

resP                    = True                   ; modify the panel plot
resP@gsnFrame           = False                  ; don't advance panel plot
resP@gsnMaximize        = True
resP@gsnPanelLabelBar   = True                   ; add common colorbar
resP@gsnPanelMainString = ""                     ; set main title
resP@gsnPanelBottom     = 0                   ; add space at bottom
resP@lbBoxEndCapStyle   = "TriangleBothEnds"
resP@lbLabelFontHeightF = 0.015
res@pmLabelBarOrthogonalPosF     = 1.0
gsn_panel(wks,plot,(/6,3/),resP)               ; now draw as one plot

frame(wks)
