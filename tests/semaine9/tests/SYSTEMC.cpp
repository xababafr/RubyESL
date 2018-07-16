#include <systemc.h>

SC_MODULE( Camera ) {
    sc_out<[Integer]> out1;
    sc_out<[Integer]> out2;
  
  

};

SC_MODULE( Processing ) {
    sc_in<[Integer]> imgT;
  
  

};


