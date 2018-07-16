#include <systemc.h>

SC_MODULE( Camera ) {
    sc_out<TYP> out1;
    sc_out<TYP> out2;
  
  

};

SC_MODULE( Processing ) {
    sc_in<TYP> imgT;
  
  

};


