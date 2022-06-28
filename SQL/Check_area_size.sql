select m.areasymbol, R.co_fips, R.r_factor, M.sapolygongeo.STIntersection(R.geom).STArea() [area], M.sapolygongeo.STIntersection(R.geom) [intersectedGeometry]
from sdm.dbo.sapolygon M,
sdm_spatial.dbo.r_factor R
where areasymbol like 'WI%'
and M.sapolygongeo.STIntersects(r.geom) = 1
and M.sapolygongeo.STIntersection(R.geom).STArea() > 0.01
order by areasymbol