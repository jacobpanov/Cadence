#include "systemc.h"
#include "mux_test.h"

mux_test::mux_test ( sc_module_name name )
:
  sc_module ( name ) ,
  y     ( "y"     ) ,
  s     ( "s"     ) ,
  i1    ( "i1"    ) ,
  i0    ( "i0"    ) ,
  mux_i ( "mux_i" )
{
  mux_i ( y, s, i1, i0 ) ;
  typedef mux_test SC_CURRENT_USER_MODULE ;
  SC_THREAD ( test_thread ) ;
}


void mux_test::expect ( sc_logic y_e )
{
  cout
    << "time="   << sc_time_stamp()
    << " s="  << s
    << " i1=" << i1
    << " i0=" << i0
    << " y="  << y
    << endl ;
  if ( y.read() != y_e ) {
    cout << "WANT:              y=" << y_e << endl ;
    cout << "TEST FAILED" << endl ;
    sc_stop ( ) ;
  }
}

void mux_test::test_thread ( )
{
  s=SC_LOGIC_0; i1=SC_LOGIC_0; i0=SC_LOGIC_1; wait(1,SC_NS); expect(SC_LOGIC_1);
  s=SC_LOGIC_0; i1=SC_LOGIC_1; i0=SC_LOGIC_0; wait(1,SC_NS); expect(SC_LOGIC_0);
  s=SC_LOGIC_1; i1=SC_LOGIC_0; i0=SC_LOGIC_1; wait(1,SC_NS); expect(SC_LOGIC_0);
  s=SC_LOGIC_1; i1=SC_LOGIC_1; i0=SC_LOGIC_0; wait(1,SC_NS); expect(SC_LOGIC_1);
  wait(1,SC_NS);
  cout << "TEST PASSED" << endl ;
}

XMSC_MODULE_EXPORT ( mux_test )
