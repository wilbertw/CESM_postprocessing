load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  casename = getenv("CASE")
  file_in = getenv("TAVGFILE")
  gridres = getenv("RESOLUTION")
  year0str = getenv("YEAR0")
  year1str = getenv("YEAR1")
  img_format = getenv("IMAGEFORMAT")
  year0 = stringtointeger(year0str)
  year1 = stringtointeger(year1str)
  psout = "DWBC"

  if (gridres.eq."gx1v5".or.gridres.eq."gx1v6".or.gridres.eq."gx1v3") then 
     ist = 290
     ien = 319
     jst = 309
  end if
  if (gridres.eq."gx3v5".or.gridres.eq."gx3v6".or.gridres.eq."gx3v7") then
     ist = 95
     ien = 99
     jst = 79
  end if

  ;; data files
  f1  = addfile(file_in,"r")
  kmt = f1->KMT(jst,ist:ien)
  ht = f1->HT(jst,ist:ien)
  vvel = f1->VVEL(0,:,jst,ist:ien)
  pd = f1->PD(0,:,jst,ist:ien)
  tlat = f1->TLAT(jst,ist:ien)
  tlon = f1->TLONG(jst,ist:ien)
  ulon = f1->ULONG(jst,ist:ien)
  z_t = f1->z_t

  tlon = tlon-360.
  ulon = ulon-360.

  meanlat = dim_avg(tlat)
  nx = dimsizes(tlon)

  z_t           = z_t/100.       ; convert from cm to m
  ht = ht/100.
  z_t@long_name = "Depth (m)"
  z_t@units     = "m"   

  sigma = (pd-1.)*1000.
  copy_VarMeta(pd,sigma)
  sigma@units = "kg/m^3"

  vvel&z_t  = z_t   
  vvel!1    = "lon_u"                ; assign new coord info
  vvel&lon_u=  ulon
  vvel@long_name = "VVEL"

  sigma&z_t  = z_t   
  sigma!1    = "lon_t"                ; assign new coord info
  sigma&lon_t=  tlon

  ht!0 = "lon_t"
  ht&lon_t = tlon

;=================================================;
; Create plot
;=================================================;
  print("plotting DWBC")
  wks  = gsn_open_wks(img_format,psout)             ; open a ps file
  gsn_define_colormap(wks,"amwg")         ; choose colormap
  i    = NhlNewColor(wks,0.8,0.8,0.8)      ; add gray to map

; resources for each panel
  res                      = True                 ; plot mods desired
  res@gsnDraw		   = False		
  res@gsnFrame		   = False		
  res@cnFillOn             = True                 ; turn on color fill
  res@cnFillMode           = "RasterFill"         ; turn on raster mode
  res@cnMissingValFillColor = "grey"
  res@lbLabelAutoStride    = True		  ; control labelbar labels
  res@cnLinesOn            = False                ; turn off contour lines
  res@cnLineLabelsOn = False			; turn the line labels off
  res@lbLabelBarOn        = True       ; Turn off labelbar
  res@lbOrientation        = "vertical" ; vertical label bar
  res@cnInfoLabelOn       = False       ; Turn off informational label
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels  = (/-12,-8,-6,-4,-2,-1,0,1,2,4,6,8,12/)
  res@trYReverse           = True       ; reverses y-axis
  res@trXMinF  = -52.
  res@trXMaxF  = -42.
  res@tmXBMode = "Manual"
  res@tmXBTickStartF = -52.
  res@tmXBTickSpacingF = 2.
  res@gsnYAxisIrregular2Linear = True
  res@gsnMaximize           = True         ; enlarge plot 
  res@gsnPaperOrientation = "Portrait"
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 2                   ; start at color 10
  res@gsnSpreadColorEnd    = 17                   ; end at color 96
  res@tiMainString = casename+", "+year0str+"-"+year1str

  ; resources for each panel
  res2                      = True                 ; plot mods desired
  res2@gsnDraw              = False
  res2@gsnFrame             = False
  res2@cnFillOn             = False                 ; turn on color fill
  res2@cnLinesOn            = True                ; turn off contour lines
  res2@cnMissingValFillColor = "black"
  res2@cnInfoLabelOn = False
  res2@cnLevelSelectionMode = "ExplicitLevels"
  res2@cnLevels  = (/27.68,27.74,27.8,27.88/)
  res2@cnLevelFlags = "LineAndLabel"
  res2@trYReverse           = True       ; reverses y-axis
  res2@gsnYAxisIrregular2Linear = True
  res2@gsnMaximize           = True         ; enlarge plot
  res2@gsnPaperOrientation = "Portrait"
  sigma@long_name = ""
  sigma@units = ""

; Create array to hold plots.
  plot0 = gsn_csm_contour(wks,vvel,res)        
  plot2 = gsn_csm_contour(wks,sigma,res2)
  overlay(plot0,plot2)         
  draw(plot0)

  txres               = True  
  txres@txFontHeightF = 0.02    
  gsn_text_ndc(wks, "Mean Latitude = "+meanlat,0.35,0.24,txres)
  frame(wks)
 end
