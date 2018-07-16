#include <systemc.h>

SC_MODULE( Camera ) {
    sc_out<int[4]> out1;
    sc_out<int[4]> out2;
  
  

};

SC_MODULE( Processing ) {
    sc_in<int[4]> imgT;
  
  

};


