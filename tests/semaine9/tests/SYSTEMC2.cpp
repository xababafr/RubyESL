#include <systemc.h>

SC_MODULE( Camera ) {
    sc_out<int[4]> out1;
    sc_out<int[4]> out2;
  
    Camera(sc_module_name scname, string name, int[4][4] video) : sc_module(scname) {
  
    }
  
    void behavior() {
    
    }
  
  

};
SC_MODULE( Processing ) {
    sc_in<int[4]> imgT;
  
    Processing(sc_module_name scname, string name, string algo) : sc_module(scname) {
  
    }
  
    void processing(img) {
    
    }
  
    void behavior() {
    
    }
  
  

};

