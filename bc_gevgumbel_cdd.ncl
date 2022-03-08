
; Load NCL libraries
; ------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;************************************************
; SCRIPT SETUP AND DECLARATIONS
;************************************************


; Get environmental variables passed by control script
; ----------------------------------------------------
  inpath1  = getenv("iPATH1")    ; path to input file (model data)
  inpath2  = getenv("iPATH2")    ; path to input file (observation data)
  outpath  = getenv("oPATH")     ; path to directory to save plots in
  infile1  = getenv("iFILE1")    ; input file (model data)
  infile2  = getenv("iFILE2")    ; input file (observation data)
  outmaps  = getenv("oMAPS")     ; path to directory to save plot/maps in

;*************************************************
;Calculate invers CDF model data
;*************************************************


f1 = addfile(inpath1+infile1+".nc","r")     ; model simulation
f2 = addfile(inpath2+infile2+".nc","r")           ; observation

var1 = f1->consecutive_dry_days_index_per_time_period(:,:,:)
var2 = f2->CDD(:,:,:)

;var1 = flt2dble (f1->consecutive_dry_days_index_per_time_period(:,:,:))           ; convert variable's type
;var2 = flt2dble (f2->consecutive_dry_days_index_per_time_period(:,:,:))

time = f1->time
LAT  = f1->LAT
LON  = f1->LON

gev_var1 = extval_mlegev (var1, 0, False)  ; dims=0
printVarSummary(gev_var1)

  location_var1 = gev_var1(:,:,0)
  scale_var1 = gev_var1(:,:,1)              ; 𝜎 for scale
  shape_var1 = gev_var1(:,:,2)              ; For 𝜉(shape) < 0 we have the Weibull distribution


  x = 1./100
  p = ispan(1,99,1)*x


  ntim  =dimsizes(var1&time)
  nlat  =dimsizes(var1&LAT)
  nlon  =dimsizes(var1&LON)
  np = dimsizes(p)
  print(np)


  reff1 = new((/np,nlat,nlon/),typeof(var1))

  shape_var1new = conform_dims (dimsizes(reff1),shape_var1,(/1,2/))
  scale_var1new = conform_dims (dimsizes(reff1),scale_var1,(/1,2/))
  location_var1new = conform_dims (dimsizes(reff1),location_var1,(/1,2/))
  p_var1new = conform_dims (dimsizes(reff1),p,(/0/))


var1_est = new((/np,nlat,nlon/),typeof(var1))

  do m=0,nlat-1
    do n=0,nlon-1
      do o=0 ,np-1
        if (ismissing(var1(1,m,n))) then
          else
          Q = location_var1new(o,m,n) - scale_var1new(o,m,n)*(log10((-1)*log10(p_var1new(o,m,n))))     ; 𝑄(𝑥) = 𝜇 − 𝜎log (− log (𝑥))
          var1_est(o,m,n) = Q
        end if
      end do
    end do
  end do

printVarSummary(var1_est)
print(var1_est(:,46,68))            ; shape < 0

print(var1_est(:,90,22))

print(var1_est(:,20,131))           ; shape > 0

print(var1_est(:,22,108))


;*************************************************
;Calculate invers CDF observation data
;*************************************************

gev_var2 = extval_mlegev (var2, 0, False)  ; dims=0
printVarSummary(gev_var2)

  location_var2 = gev_var2(:,:,0)
  scale_var2 = gev_var2(:,:,1)              ; 𝜎 for scale
  shape_var2 = gev_var2(:,:,2)              ; 𝜉 for shape

reff2 = new((/np,nlat,nlon/),typeof(var2))

  shape_var2new = conform_dims (dimsizes(reff2),shape_var2,(/1,2/))
  scale_var2new = conform_dims (dimsizes(reff2),scale_var2,(/1,2/))
  location_var2new = conform_dims (dimsizes(reff2),location_var2,(/1,2/))
  p_var2new = conform_dims (dimsizes(reff2),p,(/0/))

kosong = new((/np/),"float",getFillValue(var2))
var2_est = new((/np,nlat,nlon/),typeof(var2))

  do m=0,nlat-1
    do n=0,nlon-1
      do o=0 ,np-1
        if (ismissing(var2(1,m,n))) then
          var2_est(:,m,n) = kosong
        else
          Q = location_var2new(o,m,n) - scale_var2new(o,m,n)*(log10((-1)*log10(p_var2new(o,m,n))))     ; 𝑄(𝑥) = 𝜇 − 𝜎log (− log (𝑥))
          var2_est(o,m,n) = Q
        end if
      end do
    end do
  end do

  printVarSummary(var2_est)
  print(var2_est(:,59,51))        ; shape < 0
  print(var2_est(:,90,22))
  print(var2_est(:,69,40))           ; shape > 0
  print(var2_est(:,22,108))
  print(var2_est(:,20,273))
  print(var2_est(:,23,97))

  print(var2_est(:,46,68))
  print(var2_est(:,20,131))

  ;*************************************************
  ;Regression
  ;*************************************************

  y_index = var2_est
  x_index = var1_est

  regression = new((/2,nlat,nlon/),typeof(var1))

      do m = 0,nlat-1
        do n = 0,nlon-1
          if (ismissing(y_index(0,m,n))) then
            regression(0,m,n) = getFillValue(var2)
            regression(1,m,n) = getFillValue(var2)
            print("ada data kosong")
          else
            reg = regCoef(x_index(:,m,n),y_index(:,m,n))
            regression(0,m,n) = reg
            regression(1,m,n) = reg@yintercept
            print("tidak ada data kosong")
          end if
        end do
      end do

  printVarSummary(regression)

  slope =regression(0,:,:)
  intercept =regression(1,:,:)

  printVarSummary(slope)
  printVarSummary(intercept)

  ;*************************************************
  ;Bias Correction
  ;*************************************************

  index_biascorrected = new((/ntim,nlat,nlon/),typeof(var1))

      do m = 0,nlat-1
        do n = 0,nlon-1
          do t = 0,ntim-1
            yReg = slope(m,n)*var1(t,m,n) + intercept(m,n)
            index_biascorrected(t,m,n) = yReg
            print("index_biascorrected on progres")
          end do
        end do
      end do

      index_biascorrected!0 = "time"
      index_biascorrected!1 = "LAT"
      index_biascorrected!2 = "LON"

  printVarSummary(index_biascorrected)
  print(index_biascorrected(1,46,58))
  print(index_biascorrected(2,46,58))
  print(index_biascorrected(3,46,58))

  consecutive_dry_days_index_per_time_period = index_biascorrected

  ;*************************************************
  ;This script writes variables to a new netcdf file
  ;*************************************************


  outfile =outpath+"biascorrected_"+infile1+".nc"           ; creating new nc for biascorrected index

  if (isfilepresent(outfile)) then
  system("rm -rf "+outfile)                   ; make sure that file does not exist
  end if

  fout = addfile(outfile,"c")                ; creat new netcdf file

  ;-- begin output file settings

  setfileoption(fout,"DefineMode",True)       ;-- explicitly declare file
                                              ;   definition mode

  ; create global attributes of the file (optional)

  fAtt                   = True               ; assign file attributes
  fAtt@long_name         = "Maximum Number of Consecutive Days with Less Than 1mm of Precipitation"
  fAtt@source_file       = infile1+".nc"
  fAtt@creation_date     = systemfunc ("date")
  fAtt@institution       = "Dept. of Geophysics and Meteorology, Bogor Agricultural University (IPB)"
  fAtt@author            = "Jassica Listyarini"
  fileattdef( fout, fAtt )                ; copy file attributes

  ;-- predefine the coordinate variables and their dimensionality
  dimNames = (/"time", "LAT", "LON"/)
  dimSizes = (/ ntim , nlat, nlon/)
  dimUnlim = (/ True , False, False/)
  filedimdef(fout,dimNames,dimSizes,dimUnlim)

  ;-- predefine the the dimensionality of the variables to be written out
  filevardef(fout, "time" ,typeof(time),getvardims(time))
  filevardef(fout, "LAT" ,typeof(LAT), getvardims(LAT))
  filevardef(fout, "LON" ,typeof(LON), getvardims(LON))
  filevardef(fout, "consecutive_dry_days_index_per_time_period" ,typeof(var1), getvardims(var1))

  ;-- copy attributes associated with each variable to the file

  var_atts=0
  var_atts@long_name = "Maximum Number of Consecutive Days with Less Than 1mm of Precipitation"
  var_atts@units     = "days"
  print(var_atts)

  time_var2 = f2->TIME
  printVarSummary(time_var2)
  print(time_var2)

  filevarattdef(fout,"time" ,time_var2) ;-- copy time attributes
  filevarattdef(fout,"LAT" ,var1&LAT) ;-- copy lat attributes
  filevarattdef(fout,"LON" ,var1&LON) ;-- copy lon attributes
  filevarattdef(fout,"consecutive_dry_days_index_per_time_period", var_atts) ;-- copy var1 attributes

  ;-- explicitly exit file definition mode (not required)
  setfileoption(fout,"DefineMode",False)

  ;---NOW write the variables to the file.
  fout->time = (/time/) ;-- write time to new netCDF file
  fout->LAT = (/LAT/) ;-- write lat to new netCDF file
  fout->LON = (/LON/) ;-- write lon to new netCDF file
  fout->consecutive_dry_days_index_per_time_period = (/consecutive_dry_days_index_per_time_period/) ;-- write variable to new netCDF file
