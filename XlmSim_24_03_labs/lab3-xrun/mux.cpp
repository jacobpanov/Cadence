#include "systemc.h"
#include "mux.h"

/*mux::mux ( sc_module_name name )
:
  sc_module ( n/ame ) ,
  y  ( "y"  ) ,
  s  ( "s"  ) ,
  i1 ( "i1" ) ,
  i0 ( "i0" )
{
  typedef mux SC_CURRENT_USER_MODULE ;
  SC_METHOD ( mux_method ) ;
  sensitive << s << i1 << i0 ;
}*/


void mux::mux_method ( )
{
  if ( s == SC_LOGIC_1 )
  {
    y = b ;
  }
  else
  {
    y = a ;
  }
}
