#include "mux.h"

SC_MODULE ( mux_test )
{
  sc_signal<sc_logic> y ;
  sc_signal<sc_logic> s ;
  sc_signal<sc_logic> i1 ;
  sc_signal<sc_logic> i0 ;
  mux mux_i ;
  void test_thread ( ) ;
  SC_CTOR ( mux_test ) ;
  /*
  SC_CTOR ( mux_test ) :
    y    ( "y"      ) ,
    s    ( "s"      ) ,
    b    ( "b"      ) ,
    a    ( "a"      ) ,
    mux_i ( "mux_i" )
  {
    mux_i ( y, s, b, a ) ;
    SC_THREAD ( test_thread ) ;
  }
  */
  private :
    void expect ( sc_logic e ) ;
} ;

