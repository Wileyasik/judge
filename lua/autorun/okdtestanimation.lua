hook.Add( "PreLoadAnimations", "DynaBase.wwestuffyesyes", function( gender )
  if gender == WOS_DYNABASE.MALE or gender == WOS_DYNABASE.FEMALE
    or gender == WOS_DYNABASE.ZOMBIE or gender == WOS_DYNABASE.SHARED then
    IncludeModel( "models/alagri/okd_anim.mdl" )
  end
end )
