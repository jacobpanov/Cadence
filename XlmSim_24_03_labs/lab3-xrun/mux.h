#ifndef MUXDEF
#define MUXDEF
#include "systemc.h"

SC_MODULE ( mux )
{
  sc_out<sc_logic> y  ;
  sc_in<sc_logic>  s  ;
  sc_in<sc_logic>  b ;
  sc_in<sc_logic>  a ;
  void mux_method ( ) ;
  SC_CTOR ( mux ) :
    y ( "y" ) ,
    s ( "s" ) ,
    b ( "b" ) ,
    a ( "a" )  
  {
    SC_METHOD ( mux_method ) ;
    sensitive << s << b << a ;
  }
} ;

#endif

